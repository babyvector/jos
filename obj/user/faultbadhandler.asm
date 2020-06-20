
obj/user/faultbadhandler.debug:     file format elf32-i386


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
  800042:	e8 3a 01 00 00       	call   800181 <sys_page_alloc>
	sys_env_set_pgfault_upcall(0, (void*) 0xDeadBeef);
  800047:	83 c4 08             	add    $0x8,%esp
  80004a:	68 ef be ad de       	push   $0xdeadbeef
  80004f:	6a 00                	push   $0x0
  800051:	e8 76 02 00 00       	call   8002cc <sys_env_set_pgfault_upcall>
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
  800070:	e8 ce 00 00 00       	call   800143 <sys_getenvid>
  800075:	25 ff 03 00 00       	and    $0x3ff,%eax
  80007a:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80007d:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800082:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800087:	85 db                	test   %ebx,%ebx
  800089:	7e 07                	jle    800092 <libmain+0x2d>
		binaryname = argv[0];
  80008b:	8b 06                	mov    (%esi),%eax
  80008d:	a3 00 30 80 00       	mov    %eax,0x803000

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
  8000ae:	83 ec 08             	sub    $0x8,%esp
	close_all();
  8000b1:	e8 87 04 00 00       	call   80053d <close_all>
	sys_env_destroy(0);
  8000b6:	83 ec 0c             	sub    $0xc,%esp
  8000b9:	6a 00                	push   $0x0
  8000bb:	e8 42 00 00 00       	call   800102 <sys_env_destroy>
}
  8000c0:	83 c4 10             	add    $0x10,%esp
  8000c3:	c9                   	leave  
  8000c4:	c3                   	ret    

008000c5 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000c5:	55                   	push   %ebp
  8000c6:	89 e5                	mov    %esp,%ebp
  8000c8:	57                   	push   %edi
  8000c9:	56                   	push   %esi
  8000ca:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000cb:	b8 00 00 00 00       	mov    $0x0,%eax
  8000d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8000d6:	89 c3                	mov    %eax,%ebx
  8000d8:	89 c7                	mov    %eax,%edi
  8000da:	89 c6                	mov    %eax,%esi
  8000dc:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000e9:	ba 00 00 00 00       	mov    $0x0,%edx
  8000ee:	b8 01 00 00 00       	mov    $0x1,%eax
  8000f3:	89 d1                	mov    %edx,%ecx
  8000f5:	89 d3                	mov    %edx,%ebx
  8000f7:	89 d7                	mov    %edx,%edi
  8000f9:	89 d6                	mov    %edx,%esi
  8000fb:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000fd:	5b                   	pop    %ebx
  8000fe:	5e                   	pop    %esi
  8000ff:	5f                   	pop    %edi
  800100:	5d                   	pop    %ebp
  800101:	c3                   	ret    

00800102 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  800102:	55                   	push   %ebp
  800103:	89 e5                	mov    %esp,%ebp
  800105:	57                   	push   %edi
  800106:	56                   	push   %esi
  800107:	53                   	push   %ebx
  800108:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80010b:	b9 00 00 00 00       	mov    $0x0,%ecx
  800110:	b8 03 00 00 00       	mov    $0x3,%eax
  800115:	8b 55 08             	mov    0x8(%ebp),%edx
  800118:	89 cb                	mov    %ecx,%ebx
  80011a:	89 cf                	mov    %ecx,%edi
  80011c:	89 ce                	mov    %ecx,%esi
  80011e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800120:	85 c0                	test   %eax,%eax
  800122:	7e 17                	jle    80013b <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800124:	83 ec 0c             	sub    $0xc,%esp
  800127:	50                   	push   %eax
  800128:	6a 03                	push   $0x3
  80012a:	68 0a 1e 80 00       	push   $0x801e0a
  80012f:	6a 23                	push   $0x23
  800131:	68 27 1e 80 00       	push   $0x801e27
  800136:	e8 1a 0f 00 00       	call   801055 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80013b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800143:	55                   	push   %ebp
  800144:	89 e5                	mov    %esp,%ebp
  800146:	57                   	push   %edi
  800147:	56                   	push   %esi
  800148:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800149:	ba 00 00 00 00       	mov    $0x0,%edx
  80014e:	b8 02 00 00 00       	mov    $0x2,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_yield>:

void
sys_yield(void)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800168:	ba 00 00 00 00       	mov    $0x0,%edx
  80016d:	b8 0b 00 00 00       	mov    $0xb,%eax
  800172:	89 d1                	mov    %edx,%ecx
  800174:	89 d3                	mov    %edx,%ebx
  800176:	89 d7                	mov    %edx,%edi
  800178:	89 d6                	mov    %edx,%esi
  80017a:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80017c:	5b                   	pop    %ebx
  80017d:	5e                   	pop    %esi
  80017e:	5f                   	pop    %edi
  80017f:	5d                   	pop    %ebp
  800180:	c3                   	ret    

00800181 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800181:	55                   	push   %ebp
  800182:	89 e5                	mov    %esp,%ebp
  800184:	57                   	push   %edi
  800185:	56                   	push   %esi
  800186:	53                   	push   %ebx
  800187:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80018a:	be 00 00 00 00       	mov    $0x0,%esi
  80018f:	b8 04 00 00 00       	mov    $0x4,%eax
  800194:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800197:	8b 55 08             	mov    0x8(%ebp),%edx
  80019a:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80019d:	89 f7                	mov    %esi,%edi
  80019f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8001a1:	85 c0                	test   %eax,%eax
  8001a3:	7e 17                	jle    8001bc <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001a5:	83 ec 0c             	sub    $0xc,%esp
  8001a8:	50                   	push   %eax
  8001a9:	6a 04                	push   $0x4
  8001ab:	68 0a 1e 80 00       	push   $0x801e0a
  8001b0:	6a 23                	push   $0x23
  8001b2:	68 27 1e 80 00       	push   $0x801e27
  8001b7:	e8 99 0e 00 00       	call   801055 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001bc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001bf:	5b                   	pop    %ebx
  8001c0:	5e                   	pop    %esi
  8001c1:	5f                   	pop    %edi
  8001c2:	5d                   	pop    %ebp
  8001c3:	c3                   	ret    

008001c4 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001c4:	55                   	push   %ebp
  8001c5:	89 e5                	mov    %esp,%ebp
  8001c7:	57                   	push   %edi
  8001c8:	56                   	push   %esi
  8001c9:	53                   	push   %ebx
  8001ca:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001cd:	b8 05 00 00 00       	mov    $0x5,%eax
  8001d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001d5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001d8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001db:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001de:	8b 75 18             	mov    0x18(%ebp),%esi
  8001e1:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8001e3:	85 c0                	test   %eax,%eax
  8001e5:	7e 17                	jle    8001fe <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001e7:	83 ec 0c             	sub    $0xc,%esp
  8001ea:	50                   	push   %eax
  8001eb:	6a 05                	push   $0x5
  8001ed:	68 0a 1e 80 00       	push   $0x801e0a
  8001f2:	6a 23                	push   $0x23
  8001f4:	68 27 1e 80 00       	push   $0x801e27
  8001f9:	e8 57 0e 00 00       	call   801055 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001fe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800201:	5b                   	pop    %ebx
  800202:	5e                   	pop    %esi
  800203:	5f                   	pop    %edi
  800204:	5d                   	pop    %ebp
  800205:	c3                   	ret    

00800206 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  800206:	55                   	push   %ebp
  800207:	89 e5                	mov    %esp,%ebp
  800209:	57                   	push   %edi
  80020a:	56                   	push   %esi
  80020b:	53                   	push   %ebx
  80020c:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80020f:	bb 00 00 00 00       	mov    $0x0,%ebx
  800214:	b8 06 00 00 00       	mov    $0x6,%eax
  800219:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80021c:	8b 55 08             	mov    0x8(%ebp),%edx
  80021f:	89 df                	mov    %ebx,%edi
  800221:	89 de                	mov    %ebx,%esi
  800223:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800225:	85 c0                	test   %eax,%eax
  800227:	7e 17                	jle    800240 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800229:	83 ec 0c             	sub    $0xc,%esp
  80022c:	50                   	push   %eax
  80022d:	6a 06                	push   $0x6
  80022f:	68 0a 1e 80 00       	push   $0x801e0a
  800234:	6a 23                	push   $0x23
  800236:	68 27 1e 80 00       	push   $0x801e27
  80023b:	e8 15 0e 00 00       	call   801055 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800240:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800243:	5b                   	pop    %ebx
  800244:	5e                   	pop    %esi
  800245:	5f                   	pop    %edi
  800246:	5d                   	pop    %ebp
  800247:	c3                   	ret    

00800248 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800248:	55                   	push   %ebp
  800249:	89 e5                	mov    %esp,%ebp
  80024b:	57                   	push   %edi
  80024c:	56                   	push   %esi
  80024d:	53                   	push   %ebx
  80024e:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800251:	bb 00 00 00 00       	mov    $0x0,%ebx
  800256:	b8 08 00 00 00       	mov    $0x8,%eax
  80025b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80025e:	8b 55 08             	mov    0x8(%ebp),%edx
  800261:	89 df                	mov    %ebx,%edi
  800263:	89 de                	mov    %ebx,%esi
  800265:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800267:	85 c0                	test   %eax,%eax
  800269:	7e 17                	jle    800282 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80026b:	83 ec 0c             	sub    $0xc,%esp
  80026e:	50                   	push   %eax
  80026f:	6a 08                	push   $0x8
  800271:	68 0a 1e 80 00       	push   $0x801e0a
  800276:	6a 23                	push   $0x23
  800278:	68 27 1e 80 00       	push   $0x801e27
  80027d:	e8 d3 0d 00 00       	call   801055 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800282:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800285:	5b                   	pop    %ebx
  800286:	5e                   	pop    %esi
  800287:	5f                   	pop    %edi
  800288:	5d                   	pop    %ebp
  800289:	c3                   	ret    

0080028a <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80028a:	55                   	push   %ebp
  80028b:	89 e5                	mov    %esp,%ebp
  80028d:	57                   	push   %edi
  80028e:	56                   	push   %esi
  80028f:	53                   	push   %ebx
  800290:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800293:	bb 00 00 00 00       	mov    $0x0,%ebx
  800298:	b8 09 00 00 00       	mov    $0x9,%eax
  80029d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002a0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002a3:	89 df                	mov    %ebx,%edi
  8002a5:	89 de                	mov    %ebx,%esi
  8002a7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8002a9:	85 c0                	test   %eax,%eax
  8002ab:	7e 17                	jle    8002c4 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ad:	83 ec 0c             	sub    $0xc,%esp
  8002b0:	50                   	push   %eax
  8002b1:	6a 09                	push   $0x9
  8002b3:	68 0a 1e 80 00       	push   $0x801e0a
  8002b8:	6a 23                	push   $0x23
  8002ba:	68 27 1e 80 00       	push   $0x801e27
  8002bf:	e8 91 0d 00 00       	call   801055 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002c7:	5b                   	pop    %ebx
  8002c8:	5e                   	pop    %esi
  8002c9:	5f                   	pop    %edi
  8002ca:	5d                   	pop    %ebp
  8002cb:	c3                   	ret    

008002cc <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002cc:	55                   	push   %ebp
  8002cd:	89 e5                	mov    %esp,%ebp
  8002cf:	57                   	push   %edi
  8002d0:	56                   	push   %esi
  8002d1:	53                   	push   %ebx
  8002d2:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002d5:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002da:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002e2:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e5:	89 df                	mov    %ebx,%edi
  8002e7:	89 de                	mov    %ebx,%esi
  8002e9:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8002eb:	85 c0                	test   %eax,%eax
  8002ed:	7e 17                	jle    800306 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002ef:	83 ec 0c             	sub    $0xc,%esp
  8002f2:	50                   	push   %eax
  8002f3:	6a 0a                	push   $0xa
  8002f5:	68 0a 1e 80 00       	push   $0x801e0a
  8002fa:	6a 23                	push   $0x23
  8002fc:	68 27 1e 80 00       	push   $0x801e27
  800301:	e8 4f 0d 00 00       	call   801055 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800306:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800314:	be 00 00 00 00       	mov    $0x0,%esi
  800319:	b8 0c 00 00 00       	mov    $0xc,%eax
  80031e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800327:	8b 7d 14             	mov    0x14(%ebp),%edi
  80032a:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80032c:	5b                   	pop    %ebx
  80032d:	5e                   	pop    %esi
  80032e:	5f                   	pop    %edi
  80032f:	5d                   	pop    %ebp
  800330:	c3                   	ret    

00800331 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800331:	55                   	push   %ebp
  800332:	89 e5                	mov    %esp,%ebp
  800334:	57                   	push   %edi
  800335:	56                   	push   %esi
  800336:	53                   	push   %ebx
  800337:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80033a:	b9 00 00 00 00       	mov    $0x0,%ecx
  80033f:	b8 0d 00 00 00       	mov    $0xd,%eax
  800344:	8b 55 08             	mov    0x8(%ebp),%edx
  800347:	89 cb                	mov    %ecx,%ebx
  800349:	89 cf                	mov    %ecx,%edi
  80034b:	89 ce                	mov    %ecx,%esi
  80034d:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80034f:	85 c0                	test   %eax,%eax
  800351:	7e 17                	jle    80036a <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800353:	83 ec 0c             	sub    $0xc,%esp
  800356:	50                   	push   %eax
  800357:	6a 0d                	push   $0xd
  800359:	68 0a 1e 80 00       	push   $0x801e0a
  80035e:	6a 23                	push   $0x23
  800360:	68 27 1e 80 00       	push   $0x801e27
  800365:	e8 eb 0c 00 00       	call   801055 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80036a:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80036d:	5b                   	pop    %ebx
  80036e:	5e                   	pop    %esi
  80036f:	5f                   	pop    %edi
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800375:	8b 45 08             	mov    0x8(%ebp),%eax
  800378:	05 00 00 00 30       	add    $0x30000000,%eax
  80037d:	c1 e8 0c             	shr    $0xc,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800385:	8b 45 08             	mov    0x8(%ebp),%eax
  800388:	05 00 00 00 30       	add    $0x30000000,%eax
  80038d:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800392:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800397:	5d                   	pop    %ebp
  800398:	c3                   	ret    

00800399 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80039f:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  8003a4:	89 c2                	mov    %eax,%edx
  8003a6:	c1 ea 16             	shr    $0x16,%edx
  8003a9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003b0:	f6 c2 01             	test   $0x1,%dl
  8003b3:	74 11                	je     8003c6 <fd_alloc+0x2d>
  8003b5:	89 c2                	mov    %eax,%edx
  8003b7:	c1 ea 0c             	shr    $0xc,%edx
  8003ba:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003c1:	f6 c2 01             	test   $0x1,%dl
  8003c4:	75 09                	jne    8003cf <fd_alloc+0x36>
			*fd_store = fd;
  8003c6:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8003cd:	eb 17                	jmp    8003e6 <fd_alloc+0x4d>
  8003cf:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003d4:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003d9:	75 c9                	jne    8003a4 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003db:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003e1:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003e6:	5d                   	pop    %ebp
  8003e7:	c3                   	ret    

008003e8 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003e8:	55                   	push   %ebp
  8003e9:	89 e5                	mov    %esp,%ebp
  8003eb:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003ee:	83 f8 1f             	cmp    $0x1f,%eax
  8003f1:	77 36                	ja     800429 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003f3:	c1 e0 0c             	shl    $0xc,%eax
  8003f6:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003fb:	89 c2                	mov    %eax,%edx
  8003fd:	c1 ea 16             	shr    $0x16,%edx
  800400:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800407:	f6 c2 01             	test   $0x1,%dl
  80040a:	74 24                	je     800430 <fd_lookup+0x48>
  80040c:	89 c2                	mov    %eax,%edx
  80040e:	c1 ea 0c             	shr    $0xc,%edx
  800411:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800418:	f6 c2 01             	test   $0x1,%dl
  80041b:	74 1a                	je     800437 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  80041d:	8b 55 0c             	mov    0xc(%ebp),%edx
  800420:	89 02                	mov    %eax,(%edx)
	return 0;
  800422:	b8 00 00 00 00       	mov    $0x0,%eax
  800427:	eb 13                	jmp    80043c <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800429:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80042e:	eb 0c                	jmp    80043c <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800430:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800435:	eb 05                	jmp    80043c <fd_lookup+0x54>
  800437:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80043c:	5d                   	pop    %ebp
  80043d:	c3                   	ret    

0080043e <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80043e:	55                   	push   %ebp
  80043f:	89 e5                	mov    %esp,%ebp
  800441:	83 ec 08             	sub    $0x8,%esp
  800444:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800447:	ba b4 1e 80 00       	mov    $0x801eb4,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80044c:	eb 13                	jmp    800461 <dev_lookup+0x23>
  80044e:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800451:	39 08                	cmp    %ecx,(%eax)
  800453:	75 0c                	jne    800461 <dev_lookup+0x23>
			*dev = devtab[i];
  800455:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800458:	89 01                	mov    %eax,(%ecx)
			return 0;
  80045a:	b8 00 00 00 00       	mov    $0x0,%eax
  80045f:	eb 2e                	jmp    80048f <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800461:	8b 02                	mov    (%edx),%eax
  800463:	85 c0                	test   %eax,%eax
  800465:	75 e7                	jne    80044e <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800467:	a1 04 40 80 00       	mov    0x804004,%eax
  80046c:	8b 40 48             	mov    0x48(%eax),%eax
  80046f:	83 ec 04             	sub    $0x4,%esp
  800472:	51                   	push   %ecx
  800473:	50                   	push   %eax
  800474:	68 38 1e 80 00       	push   $0x801e38
  800479:	e8 b0 0c 00 00       	call   80112e <cprintf>
	*dev = 0;
  80047e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800481:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800487:	83 c4 10             	add    $0x10,%esp
  80048a:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80048f:	c9                   	leave  
  800490:	c3                   	ret    

00800491 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800491:	55                   	push   %ebp
  800492:	89 e5                	mov    %esp,%ebp
  800494:	56                   	push   %esi
  800495:	53                   	push   %ebx
  800496:	83 ec 10             	sub    $0x10,%esp
  800499:	8b 75 08             	mov    0x8(%ebp),%esi
  80049c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80049f:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004a2:	50                   	push   %eax
  8004a3:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  8004a9:	c1 e8 0c             	shr    $0xc,%eax
  8004ac:	50                   	push   %eax
  8004ad:	e8 36 ff ff ff       	call   8003e8 <fd_lookup>
  8004b2:	83 c4 08             	add    $0x8,%esp
  8004b5:	85 c0                	test   %eax,%eax
  8004b7:	78 05                	js     8004be <fd_close+0x2d>
	    || fd != fd2)
  8004b9:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004bc:	74 0c                	je     8004ca <fd_close+0x39>
		return (must_exist ? r : 0);
  8004be:	84 db                	test   %bl,%bl
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	0f 44 c2             	cmove  %edx,%eax
  8004c8:	eb 41                	jmp    80050b <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ca:	83 ec 08             	sub    $0x8,%esp
  8004cd:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004d0:	50                   	push   %eax
  8004d1:	ff 36                	pushl  (%esi)
  8004d3:	e8 66 ff ff ff       	call   80043e <dev_lookup>
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
  8004dd:	85 c0                	test   %eax,%eax
  8004df:	78 1a                	js     8004fb <fd_close+0x6a>
		if (dev->dev_close)
  8004e1:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004e4:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004e7:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ec:	85 c0                	test   %eax,%eax
  8004ee:	74 0b                	je     8004fb <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004f0:	83 ec 0c             	sub    $0xc,%esp
  8004f3:	56                   	push   %esi
  8004f4:	ff d0                	call   *%eax
  8004f6:	89 c3                	mov    %eax,%ebx
  8004f8:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004fb:	83 ec 08             	sub    $0x8,%esp
  8004fe:	56                   	push   %esi
  8004ff:	6a 00                	push   $0x0
  800501:	e8 00 fd ff ff       	call   800206 <sys_page_unmap>
	return r;
  800506:	83 c4 10             	add    $0x10,%esp
  800509:	89 d8                	mov    %ebx,%eax
}
  80050b:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80050e:	5b                   	pop    %ebx
  80050f:	5e                   	pop    %esi
  800510:	5d                   	pop    %ebp
  800511:	c3                   	ret    

00800512 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  800512:	55                   	push   %ebp
  800513:	89 e5                	mov    %esp,%ebp
  800515:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800518:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80051b:	50                   	push   %eax
  80051c:	ff 75 08             	pushl  0x8(%ebp)
  80051f:	e8 c4 fe ff ff       	call   8003e8 <fd_lookup>
  800524:	83 c4 08             	add    $0x8,%esp
  800527:	85 c0                	test   %eax,%eax
  800529:	78 10                	js     80053b <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80052b:	83 ec 08             	sub    $0x8,%esp
  80052e:	6a 01                	push   $0x1
  800530:	ff 75 f4             	pushl  -0xc(%ebp)
  800533:	e8 59 ff ff ff       	call   800491 <fd_close>
  800538:	83 c4 10             	add    $0x10,%esp
}
  80053b:	c9                   	leave  
  80053c:	c3                   	ret    

0080053d <close_all>:

void
close_all(void)
{
  80053d:	55                   	push   %ebp
  80053e:	89 e5                	mov    %esp,%ebp
  800540:	53                   	push   %ebx
  800541:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800544:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800549:	83 ec 0c             	sub    $0xc,%esp
  80054c:	53                   	push   %ebx
  80054d:	e8 c0 ff ff ff       	call   800512 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800552:	83 c3 01             	add    $0x1,%ebx
  800555:	83 c4 10             	add    $0x10,%esp
  800558:	83 fb 20             	cmp    $0x20,%ebx
  80055b:	75 ec                	jne    800549 <close_all+0xc>
		close(i);
}
  80055d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800560:	c9                   	leave  
  800561:	c3                   	ret    

00800562 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800562:	55                   	push   %ebp
  800563:	89 e5                	mov    %esp,%ebp
  800565:	57                   	push   %edi
  800566:	56                   	push   %esi
  800567:	53                   	push   %ebx
  800568:	83 ec 2c             	sub    $0x2c,%esp
  80056b:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80056e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800571:	50                   	push   %eax
  800572:	ff 75 08             	pushl  0x8(%ebp)
  800575:	e8 6e fe ff ff       	call   8003e8 <fd_lookup>
  80057a:	83 c4 08             	add    $0x8,%esp
  80057d:	85 c0                	test   %eax,%eax
  80057f:	0f 88 c1 00 00 00    	js     800646 <dup+0xe4>
		return r;
	close(newfdnum);
  800585:	83 ec 0c             	sub    $0xc,%esp
  800588:	56                   	push   %esi
  800589:	e8 84 ff ff ff       	call   800512 <close>

	newfd = INDEX2FD(newfdnum);
  80058e:	89 f3                	mov    %esi,%ebx
  800590:	c1 e3 0c             	shl    $0xc,%ebx
  800593:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800599:	83 c4 04             	add    $0x4,%esp
  80059c:	ff 75 e4             	pushl  -0x1c(%ebp)
  80059f:	e8 de fd ff ff       	call   800382 <fd2data>
  8005a4:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  8005a6:	89 1c 24             	mov    %ebx,(%esp)
  8005a9:	e8 d4 fd ff ff       	call   800382 <fd2data>
  8005ae:	83 c4 10             	add    $0x10,%esp
  8005b1:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  8005b4:	89 f8                	mov    %edi,%eax
  8005b6:	c1 e8 16             	shr    $0x16,%eax
  8005b9:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005c0:	a8 01                	test   $0x1,%al
  8005c2:	74 37                	je     8005fb <dup+0x99>
  8005c4:	89 f8                	mov    %edi,%eax
  8005c6:	c1 e8 0c             	shr    $0xc,%eax
  8005c9:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005d0:	f6 c2 01             	test   $0x1,%dl
  8005d3:	74 26                	je     8005fb <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005d5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005dc:	83 ec 0c             	sub    $0xc,%esp
  8005df:	25 07 0e 00 00       	and    $0xe07,%eax
  8005e4:	50                   	push   %eax
  8005e5:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005e8:	6a 00                	push   $0x0
  8005ea:	57                   	push   %edi
  8005eb:	6a 00                	push   $0x0
  8005ed:	e8 d2 fb ff ff       	call   8001c4 <sys_page_map>
  8005f2:	89 c7                	mov    %eax,%edi
  8005f4:	83 c4 20             	add    $0x20,%esp
  8005f7:	85 c0                	test   %eax,%eax
  8005f9:	78 2e                	js     800629 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fb:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fe:	89 d0                	mov    %edx,%eax
  800600:	c1 e8 0c             	shr    $0xc,%eax
  800603:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  80060a:	83 ec 0c             	sub    $0xc,%esp
  80060d:	25 07 0e 00 00       	and    $0xe07,%eax
  800612:	50                   	push   %eax
  800613:	53                   	push   %ebx
  800614:	6a 00                	push   $0x0
  800616:	52                   	push   %edx
  800617:	6a 00                	push   $0x0
  800619:	e8 a6 fb ff ff       	call   8001c4 <sys_page_map>
  80061e:	89 c7                	mov    %eax,%edi
  800620:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800623:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800625:	85 ff                	test   %edi,%edi
  800627:	79 1d                	jns    800646 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800629:	83 ec 08             	sub    $0x8,%esp
  80062c:	53                   	push   %ebx
  80062d:	6a 00                	push   $0x0
  80062f:	e8 d2 fb ff ff       	call   800206 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800634:	83 c4 08             	add    $0x8,%esp
  800637:	ff 75 d4             	pushl  -0x2c(%ebp)
  80063a:	6a 00                	push   $0x0
  80063c:	e8 c5 fb ff ff       	call   800206 <sys_page_unmap>
	return r;
  800641:	83 c4 10             	add    $0x10,%esp
  800644:	89 f8                	mov    %edi,%eax
}
  800646:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800649:	5b                   	pop    %ebx
  80064a:	5e                   	pop    %esi
  80064b:	5f                   	pop    %edi
  80064c:	5d                   	pop    %ebp
  80064d:	c3                   	ret    

0080064e <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80064e:	55                   	push   %ebp
  80064f:	89 e5                	mov    %esp,%ebp
  800651:	53                   	push   %ebx
  800652:	83 ec 14             	sub    $0x14,%esp
  800655:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800658:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80065b:	50                   	push   %eax
  80065c:	53                   	push   %ebx
  80065d:	e8 86 fd ff ff       	call   8003e8 <fd_lookup>
  800662:	83 c4 08             	add    $0x8,%esp
  800665:	89 c2                	mov    %eax,%edx
  800667:	85 c0                	test   %eax,%eax
  800669:	78 6d                	js     8006d8 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80066b:	83 ec 08             	sub    $0x8,%esp
  80066e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800671:	50                   	push   %eax
  800672:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800675:	ff 30                	pushl  (%eax)
  800677:	e8 c2 fd ff ff       	call   80043e <dev_lookup>
  80067c:	83 c4 10             	add    $0x10,%esp
  80067f:	85 c0                	test   %eax,%eax
  800681:	78 4c                	js     8006cf <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800683:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800686:	8b 42 08             	mov    0x8(%edx),%eax
  800689:	83 e0 03             	and    $0x3,%eax
  80068c:	83 f8 01             	cmp    $0x1,%eax
  80068f:	75 21                	jne    8006b2 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800691:	a1 04 40 80 00       	mov    0x804004,%eax
  800696:	8b 40 48             	mov    0x48(%eax),%eax
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	53                   	push   %ebx
  80069d:	50                   	push   %eax
  80069e:	68 79 1e 80 00       	push   $0x801e79
  8006a3:	e8 86 0a 00 00       	call   80112e <cprintf>
		return -E_INVAL;
  8006a8:	83 c4 10             	add    $0x10,%esp
  8006ab:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  8006b0:	eb 26                	jmp    8006d8 <read+0x8a>
	}
	if (!dev->dev_read)
  8006b2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8006b5:	8b 40 08             	mov    0x8(%eax),%eax
  8006b8:	85 c0                	test   %eax,%eax
  8006ba:	74 17                	je     8006d3 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006bc:	83 ec 04             	sub    $0x4,%esp
  8006bf:	ff 75 10             	pushl  0x10(%ebp)
  8006c2:	ff 75 0c             	pushl  0xc(%ebp)
  8006c5:	52                   	push   %edx
  8006c6:	ff d0                	call   *%eax
  8006c8:	89 c2                	mov    %eax,%edx
  8006ca:	83 c4 10             	add    $0x10,%esp
  8006cd:	eb 09                	jmp    8006d8 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006cf:	89 c2                	mov    %eax,%edx
  8006d1:	eb 05                	jmp    8006d8 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006d3:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006d8:	89 d0                	mov    %edx,%eax
  8006da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006dd:	c9                   	leave  
  8006de:	c3                   	ret    

008006df <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006df:	55                   	push   %ebp
  8006e0:	89 e5                	mov    %esp,%ebp
  8006e2:	57                   	push   %edi
  8006e3:	56                   	push   %esi
  8006e4:	53                   	push   %ebx
  8006e5:	83 ec 0c             	sub    $0xc,%esp
  8006e8:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006eb:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ee:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006f3:	eb 21                	jmp    800716 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006f5:	83 ec 04             	sub    $0x4,%esp
  8006f8:	89 f0                	mov    %esi,%eax
  8006fa:	29 d8                	sub    %ebx,%eax
  8006fc:	50                   	push   %eax
  8006fd:	89 d8                	mov    %ebx,%eax
  8006ff:	03 45 0c             	add    0xc(%ebp),%eax
  800702:	50                   	push   %eax
  800703:	57                   	push   %edi
  800704:	e8 45 ff ff ff       	call   80064e <read>
		if (m < 0)
  800709:	83 c4 10             	add    $0x10,%esp
  80070c:	85 c0                	test   %eax,%eax
  80070e:	78 10                	js     800720 <readn+0x41>
			return m;
		if (m == 0)
  800710:	85 c0                	test   %eax,%eax
  800712:	74 0a                	je     80071e <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  800714:	01 c3                	add    %eax,%ebx
  800716:	39 f3                	cmp    %esi,%ebx
  800718:	72 db                	jb     8006f5 <readn+0x16>
  80071a:	89 d8                	mov    %ebx,%eax
  80071c:	eb 02                	jmp    800720 <readn+0x41>
  80071e:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800720:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800723:	5b                   	pop    %ebx
  800724:	5e                   	pop    %esi
  800725:	5f                   	pop    %edi
  800726:	5d                   	pop    %ebp
  800727:	c3                   	ret    

00800728 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800728:	55                   	push   %ebp
  800729:	89 e5                	mov    %esp,%ebp
  80072b:	53                   	push   %ebx
  80072c:	83 ec 14             	sub    $0x14,%esp
  80072f:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800732:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800735:	50                   	push   %eax
  800736:	53                   	push   %ebx
  800737:	e8 ac fc ff ff       	call   8003e8 <fd_lookup>
  80073c:	83 c4 08             	add    $0x8,%esp
  80073f:	89 c2                	mov    %eax,%edx
  800741:	85 c0                	test   %eax,%eax
  800743:	78 68                	js     8007ad <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800745:	83 ec 08             	sub    $0x8,%esp
  800748:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80074b:	50                   	push   %eax
  80074c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80074f:	ff 30                	pushl  (%eax)
  800751:	e8 e8 fc ff ff       	call   80043e <dev_lookup>
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	85 c0                	test   %eax,%eax
  80075b:	78 47                	js     8007a4 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80075d:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800760:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800764:	75 21                	jne    800787 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800766:	a1 04 40 80 00       	mov    0x804004,%eax
  80076b:	8b 40 48             	mov    0x48(%eax),%eax
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	53                   	push   %ebx
  800772:	50                   	push   %eax
  800773:	68 95 1e 80 00       	push   $0x801e95
  800778:	e8 b1 09 00 00       	call   80112e <cprintf>
		return -E_INVAL;
  80077d:	83 c4 10             	add    $0x10,%esp
  800780:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800785:	eb 26                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800787:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80078a:	8b 52 0c             	mov    0xc(%edx),%edx
  80078d:	85 d2                	test   %edx,%edx
  80078f:	74 17                	je     8007a8 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800791:	83 ec 04             	sub    $0x4,%esp
  800794:	ff 75 10             	pushl  0x10(%ebp)
  800797:	ff 75 0c             	pushl  0xc(%ebp)
  80079a:	50                   	push   %eax
  80079b:	ff d2                	call   *%edx
  80079d:	89 c2                	mov    %eax,%edx
  80079f:	83 c4 10             	add    $0x10,%esp
  8007a2:	eb 09                	jmp    8007ad <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007a4:	89 c2                	mov    %eax,%edx
  8007a6:	eb 05                	jmp    8007ad <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  8007a8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  8007ad:	89 d0                	mov    %edx,%eax
  8007af:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8007b2:	c9                   	leave  
  8007b3:	c3                   	ret    

008007b4 <seek>:

int
seek(int fdnum, off_t offset)
{
  8007b4:	55                   	push   %ebp
  8007b5:	89 e5                	mov    %esp,%ebp
  8007b7:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007ba:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007bd:	50                   	push   %eax
  8007be:	ff 75 08             	pushl  0x8(%ebp)
  8007c1:	e8 22 fc ff ff       	call   8003e8 <fd_lookup>
  8007c6:	83 c4 08             	add    $0x8,%esp
  8007c9:	85 c0                	test   %eax,%eax
  8007cb:	78 0e                	js     8007db <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007cd:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007d0:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007d3:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007d6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007db:	c9                   	leave  
  8007dc:	c3                   	ret    

008007dd <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007dd:	55                   	push   %ebp
  8007de:	89 e5                	mov    %esp,%ebp
  8007e0:	53                   	push   %ebx
  8007e1:	83 ec 14             	sub    $0x14,%esp
  8007e4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007e7:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007ea:	50                   	push   %eax
  8007eb:	53                   	push   %ebx
  8007ec:	e8 f7 fb ff ff       	call   8003e8 <fd_lookup>
  8007f1:	83 c4 08             	add    $0x8,%esp
  8007f4:	89 c2                	mov    %eax,%edx
  8007f6:	85 c0                	test   %eax,%eax
  8007f8:	78 65                	js     80085f <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007fa:	83 ec 08             	sub    $0x8,%esp
  8007fd:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800800:	50                   	push   %eax
  800801:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800804:	ff 30                	pushl  (%eax)
  800806:	e8 33 fc ff ff       	call   80043e <dev_lookup>
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	85 c0                	test   %eax,%eax
  800810:	78 44                	js     800856 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800812:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800815:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800819:	75 21                	jne    80083c <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  80081b:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800820:	8b 40 48             	mov    0x48(%eax),%eax
  800823:	83 ec 04             	sub    $0x4,%esp
  800826:	53                   	push   %ebx
  800827:	50                   	push   %eax
  800828:	68 58 1e 80 00       	push   $0x801e58
  80082d:	e8 fc 08 00 00       	call   80112e <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800832:	83 c4 10             	add    $0x10,%esp
  800835:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80083a:	eb 23                	jmp    80085f <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80083c:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80083f:	8b 52 18             	mov    0x18(%edx),%edx
  800842:	85 d2                	test   %edx,%edx
  800844:	74 14                	je     80085a <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800846:	83 ec 08             	sub    $0x8,%esp
  800849:	ff 75 0c             	pushl  0xc(%ebp)
  80084c:	50                   	push   %eax
  80084d:	ff d2                	call   *%edx
  80084f:	89 c2                	mov    %eax,%edx
  800851:	83 c4 10             	add    $0x10,%esp
  800854:	eb 09                	jmp    80085f <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800856:	89 c2                	mov    %eax,%edx
  800858:	eb 05                	jmp    80085f <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80085a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80085f:	89 d0                	mov    %edx,%eax
  800861:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800864:	c9                   	leave  
  800865:	c3                   	ret    

00800866 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800866:	55                   	push   %ebp
  800867:	89 e5                	mov    %esp,%ebp
  800869:	53                   	push   %ebx
  80086a:	83 ec 14             	sub    $0x14,%esp
  80086d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800870:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800873:	50                   	push   %eax
  800874:	ff 75 08             	pushl  0x8(%ebp)
  800877:	e8 6c fb ff ff       	call   8003e8 <fd_lookup>
  80087c:	83 c4 08             	add    $0x8,%esp
  80087f:	89 c2                	mov    %eax,%edx
  800881:	85 c0                	test   %eax,%eax
  800883:	78 58                	js     8008dd <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800885:	83 ec 08             	sub    $0x8,%esp
  800888:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80088b:	50                   	push   %eax
  80088c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80088f:	ff 30                	pushl  (%eax)
  800891:	e8 a8 fb ff ff       	call   80043e <dev_lookup>
  800896:	83 c4 10             	add    $0x10,%esp
  800899:	85 c0                	test   %eax,%eax
  80089b:	78 37                	js     8008d4 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80089d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  8008a0:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  8008a4:	74 32                	je     8008d8 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  8008a6:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  8008a9:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  8008b0:	00 00 00 
	stat->st_isdir = 0;
  8008b3:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008ba:	00 00 00 
	stat->st_dev = dev;
  8008bd:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008c3:	83 ec 08             	sub    $0x8,%esp
  8008c6:	53                   	push   %ebx
  8008c7:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ca:	ff 50 14             	call   *0x14(%eax)
  8008cd:	89 c2                	mov    %eax,%edx
  8008cf:	83 c4 10             	add    $0x10,%esp
  8008d2:	eb 09                	jmp    8008dd <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008d4:	89 c2                	mov    %eax,%edx
  8008d6:	eb 05                	jmp    8008dd <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008d8:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008dd:	89 d0                	mov    %edx,%eax
  8008df:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008e2:	c9                   	leave  
  8008e3:	c3                   	ret    

008008e4 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008e4:	55                   	push   %ebp
  8008e5:	89 e5                	mov    %esp,%ebp
  8008e7:	56                   	push   %esi
  8008e8:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008e9:	83 ec 08             	sub    $0x8,%esp
  8008ec:	6a 00                	push   $0x0
  8008ee:	ff 75 08             	pushl  0x8(%ebp)
  8008f1:	e8 dc 01 00 00       	call   800ad2 <open>
  8008f6:	89 c3                	mov    %eax,%ebx
  8008f8:	83 c4 10             	add    $0x10,%esp
  8008fb:	85 c0                	test   %eax,%eax
  8008fd:	78 1b                	js     80091a <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008ff:	83 ec 08             	sub    $0x8,%esp
  800902:	ff 75 0c             	pushl  0xc(%ebp)
  800905:	50                   	push   %eax
  800906:	e8 5b ff ff ff       	call   800866 <fstat>
  80090b:	89 c6                	mov    %eax,%esi
	close(fd);
  80090d:	89 1c 24             	mov    %ebx,(%esp)
  800910:	e8 fd fb ff ff       	call   800512 <close>
	return r;
  800915:	83 c4 10             	add    $0x10,%esp
  800918:	89 f0                	mov    %esi,%eax
}
  80091a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80091d:	5b                   	pop    %ebx
  80091e:	5e                   	pop    %esi
  80091f:	5d                   	pop    %ebp
  800920:	c3                   	ret    

00800921 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800921:	55                   	push   %ebp
  800922:	89 e5                	mov    %esp,%ebp
  800924:	56                   	push   %esi
  800925:	53                   	push   %ebx
  800926:	89 c6                	mov    %eax,%esi
  800928:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80092a:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800931:	75 12                	jne    800945 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800933:	83 ec 0c             	sub    $0xc,%esp
  800936:	6a 01                	push   $0x1
  800938:	e8 a7 11 00 00       	call   801ae4 <ipc_find_env>
  80093d:	a3 00 40 80 00       	mov    %eax,0x804000
  800942:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800945:	6a 07                	push   $0x7
  800947:	68 00 50 80 00       	push   $0x805000
  80094c:	56                   	push   %esi
  80094d:	ff 35 00 40 80 00    	pushl  0x804000
  800953:	e8 49 11 00 00       	call   801aa1 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  800958:	83 c4 0c             	add    $0xc,%esp
  80095b:	6a 00                	push   $0x0
  80095d:	53                   	push   %ebx
  80095e:	6a 00                	push   $0x0
  800960:	e8 df 10 00 00       	call   801a44 <ipc_recv>
}
  800965:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800968:	5b                   	pop    %ebx
  800969:	5e                   	pop    %esi
  80096a:	5d                   	pop    %ebp
  80096b:	c3                   	ret    

0080096c <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80096c:	55                   	push   %ebp
  80096d:	89 e5                	mov    %esp,%ebp
  80096f:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800972:	8b 45 08             	mov    0x8(%ebp),%eax
  800975:	8b 40 0c             	mov    0xc(%eax),%eax
  800978:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80097d:	8b 45 0c             	mov    0xc(%ebp),%eax
  800980:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800985:	ba 00 00 00 00       	mov    $0x0,%edx
  80098a:	b8 02 00 00 00       	mov    $0x2,%eax
  80098f:	e8 8d ff ff ff       	call   800921 <fsipc>
}
  800994:	c9                   	leave  
  800995:	c3                   	ret    

00800996 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800996:	55                   	push   %ebp
  800997:	89 e5                	mov    %esp,%ebp
  800999:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80099c:	8b 45 08             	mov    0x8(%ebp),%eax
  80099f:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a2:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  8009a7:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ac:	b8 06 00 00 00       	mov    $0x6,%eax
  8009b1:	e8 6b ff ff ff       	call   800921 <fsipc>
}
  8009b6:	c9                   	leave  
  8009b7:	c3                   	ret    

008009b8 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009b8:	55                   	push   %ebp
  8009b9:	89 e5                	mov    %esp,%ebp
  8009bb:	53                   	push   %ebx
  8009bc:	83 ec 04             	sub    $0x4,%esp
  8009bf:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009c2:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c5:	8b 40 0c             	mov    0xc(%eax),%eax
  8009c8:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009cd:	ba 00 00 00 00       	mov    $0x0,%edx
  8009d2:	b8 05 00 00 00       	mov    $0x5,%eax
  8009d7:	e8 45 ff ff ff       	call   800921 <fsipc>
  8009dc:	85 c0                	test   %eax,%eax
  8009de:	78 2c                	js     800a0c <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009e0:	83 ec 08             	sub    $0x8,%esp
  8009e3:	68 00 50 80 00       	push   $0x805000
  8009e8:	53                   	push   %ebx
  8009e9:	e8 0f 0d 00 00       	call   8016fd <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009ee:	a1 80 50 80 00       	mov    0x805080,%eax
  8009f3:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009f9:	a1 84 50 80 00       	mov    0x805084,%eax
  8009fe:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  800a04:	83 c4 10             	add    $0x10,%esp
  800a07:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800a0c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800a0f:	c9                   	leave  
  800a10:	c3                   	ret    

00800a11 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  800a11:	55                   	push   %ebp
  800a12:	89 e5                	mov    %esp,%ebp
  800a14:	83 ec 0c             	sub    $0xc,%esp
  800a17:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a1a:	8b 55 08             	mov    0x8(%ebp),%edx
  800a1d:	8b 52 0c             	mov    0xc(%edx),%edx
  800a20:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a26:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a2b:	50                   	push   %eax
  800a2c:	ff 75 0c             	pushl  0xc(%ebp)
  800a2f:	68 08 50 80 00       	push   $0x805008
  800a34:	e8 56 0e 00 00       	call   80188f <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a39:	ba 00 00 00 00       	mov    $0x0,%edx
  800a3e:	b8 04 00 00 00       	mov    $0x4,%eax
  800a43:	e8 d9 fe ff ff       	call   800921 <fsipc>
	//panic("devfile_write not implemented");
}
  800a48:	c9                   	leave  
  800a49:	c3                   	ret    

00800a4a <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a4a:	55                   	push   %ebp
  800a4b:	89 e5                	mov    %esp,%ebp
  800a4d:	56                   	push   %esi
  800a4e:	53                   	push   %ebx
  800a4f:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a52:	8b 45 08             	mov    0x8(%ebp),%eax
  800a55:	8b 40 0c             	mov    0xc(%eax),%eax
  800a58:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a5d:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a63:	ba 00 00 00 00       	mov    $0x0,%edx
  800a68:	b8 03 00 00 00       	mov    $0x3,%eax
  800a6d:	e8 af fe ff ff       	call   800921 <fsipc>
  800a72:	89 c3                	mov    %eax,%ebx
  800a74:	85 c0                	test   %eax,%eax
  800a76:	78 51                	js     800ac9 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a78:	39 c6                	cmp    %eax,%esi
  800a7a:	73 19                	jae    800a95 <devfile_read+0x4b>
  800a7c:	68 c4 1e 80 00       	push   $0x801ec4
  800a81:	68 cb 1e 80 00       	push   $0x801ecb
  800a86:	68 80 00 00 00       	push   $0x80
  800a8b:	68 e0 1e 80 00       	push   $0x801ee0
  800a90:	e8 c0 05 00 00       	call   801055 <_panic>
	assert(r <= PGSIZE);
  800a95:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a9a:	7e 19                	jle    800ab5 <devfile_read+0x6b>
  800a9c:	68 eb 1e 80 00       	push   $0x801eeb
  800aa1:	68 cb 1e 80 00       	push   $0x801ecb
  800aa6:	68 81 00 00 00       	push   $0x81
  800aab:	68 e0 1e 80 00       	push   $0x801ee0
  800ab0:	e8 a0 05 00 00       	call   801055 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800ab5:	83 ec 04             	sub    $0x4,%esp
  800ab8:	50                   	push   %eax
  800ab9:	68 00 50 80 00       	push   $0x805000
  800abe:	ff 75 0c             	pushl  0xc(%ebp)
  800ac1:	e8 c9 0d 00 00       	call   80188f <memmove>
	return r;
  800ac6:	83 c4 10             	add    $0x10,%esp
}
  800ac9:	89 d8                	mov    %ebx,%eax
  800acb:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ace:	5b                   	pop    %ebx
  800acf:	5e                   	pop    %esi
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	53                   	push   %ebx
  800ad6:	83 ec 20             	sub    $0x20,%esp
  800ad9:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800adc:	53                   	push   %ebx
  800add:	e8 e2 0b 00 00       	call   8016c4 <strlen>
  800ae2:	83 c4 10             	add    $0x10,%esp
  800ae5:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800aea:	7f 67                	jg     800b53 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800aec:	83 ec 0c             	sub    $0xc,%esp
  800aef:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800af2:	50                   	push   %eax
  800af3:	e8 a1 f8 ff ff       	call   800399 <fd_alloc>
  800af8:	83 c4 10             	add    $0x10,%esp
		return r;
  800afb:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800afd:	85 c0                	test   %eax,%eax
  800aff:	78 57                	js     800b58 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800b01:	83 ec 08             	sub    $0x8,%esp
  800b04:	53                   	push   %ebx
  800b05:	68 00 50 80 00       	push   $0x805000
  800b0a:	e8 ee 0b 00 00       	call   8016fd <strcpy>
	fsipcbuf.open.req_omode = mode;
  800b0f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b12:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b17:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b1a:	b8 01 00 00 00       	mov    $0x1,%eax
  800b1f:	e8 fd fd ff ff       	call   800921 <fsipc>
  800b24:	89 c3                	mov    %eax,%ebx
  800b26:	83 c4 10             	add    $0x10,%esp
  800b29:	85 c0                	test   %eax,%eax
  800b2b:	79 14                	jns    800b41 <open+0x6f>
		
		fd_close(fd, 0);
  800b2d:	83 ec 08             	sub    $0x8,%esp
  800b30:	6a 00                	push   $0x0
  800b32:	ff 75 f4             	pushl  -0xc(%ebp)
  800b35:	e8 57 f9 ff ff       	call   800491 <fd_close>
		return r;
  800b3a:	83 c4 10             	add    $0x10,%esp
  800b3d:	89 da                	mov    %ebx,%edx
  800b3f:	eb 17                	jmp    800b58 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  800b41:	83 ec 0c             	sub    $0xc,%esp
  800b44:	ff 75 f4             	pushl  -0xc(%ebp)
  800b47:	e8 26 f8 ff ff       	call   800372 <fd2num>
  800b4c:	89 c2                	mov    %eax,%edx
  800b4e:	83 c4 10             	add    $0x10,%esp
  800b51:	eb 05                	jmp    800b58 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b53:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  800b58:	89 d0                	mov    %edx,%eax
  800b5a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b65:	ba 00 00 00 00       	mov    $0x0,%edx
  800b6a:	b8 08 00 00 00       	mov    $0x8,%eax
  800b6f:	e8 ad fd ff ff       	call   800921 <fsipc>
}
  800b74:	c9                   	leave  
  800b75:	c3                   	ret    

00800b76 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b76:	55                   	push   %ebp
  800b77:	89 e5                	mov    %esp,%ebp
  800b79:	56                   	push   %esi
  800b7a:	53                   	push   %ebx
  800b7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b7e:	83 ec 0c             	sub    $0xc,%esp
  800b81:	ff 75 08             	pushl  0x8(%ebp)
  800b84:	e8 f9 f7 ff ff       	call   800382 <fd2data>
  800b89:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b8b:	83 c4 08             	add    $0x8,%esp
  800b8e:	68 f7 1e 80 00       	push   $0x801ef7
  800b93:	53                   	push   %ebx
  800b94:	e8 64 0b 00 00       	call   8016fd <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b99:	8b 46 04             	mov    0x4(%esi),%eax
  800b9c:	2b 06                	sub    (%esi),%eax
  800b9e:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800ba4:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800bab:	00 00 00 
	stat->st_dev = &devpipe;
  800bae:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800bb5:	30 80 00 
	return 0;
}
  800bb8:	b8 00 00 00 00       	mov    $0x0,%eax
  800bbd:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800bc0:	5b                   	pop    %ebx
  800bc1:	5e                   	pop    %esi
  800bc2:	5d                   	pop    %ebp
  800bc3:	c3                   	ret    

00800bc4 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bc4:	55                   	push   %ebp
  800bc5:	89 e5                	mov    %esp,%ebp
  800bc7:	53                   	push   %ebx
  800bc8:	83 ec 0c             	sub    $0xc,%esp
  800bcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bce:	53                   	push   %ebx
  800bcf:	6a 00                	push   $0x0
  800bd1:	e8 30 f6 ff ff       	call   800206 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bd6:	89 1c 24             	mov    %ebx,(%esp)
  800bd9:	e8 a4 f7 ff ff       	call   800382 <fd2data>
  800bde:	83 c4 08             	add    $0x8,%esp
  800be1:	50                   	push   %eax
  800be2:	6a 00                	push   $0x0
  800be4:	e8 1d f6 ff ff       	call   800206 <sys_page_unmap>
}
  800be9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bec:	c9                   	leave  
  800bed:	c3                   	ret    

00800bee <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bee:	55                   	push   %ebp
  800bef:	89 e5                	mov    %esp,%ebp
  800bf1:	57                   	push   %edi
  800bf2:	56                   	push   %esi
  800bf3:	53                   	push   %ebx
  800bf4:	83 ec 1c             	sub    $0x1c,%esp
  800bf7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bfa:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bfc:	a1 04 40 80 00       	mov    0x804004,%eax
  800c01:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800c04:	83 ec 0c             	sub    $0xc,%esp
  800c07:	ff 75 e0             	pushl  -0x20(%ebp)
  800c0a:	e8 0e 0f 00 00       	call   801b1d <pageref>
  800c0f:	89 c3                	mov    %eax,%ebx
  800c11:	89 3c 24             	mov    %edi,(%esp)
  800c14:	e8 04 0f 00 00       	call   801b1d <pageref>
  800c19:	83 c4 10             	add    $0x10,%esp
  800c1c:	39 c3                	cmp    %eax,%ebx
  800c1e:	0f 94 c1             	sete   %cl
  800c21:	0f b6 c9             	movzbl %cl,%ecx
  800c24:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c27:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c2d:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c30:	39 ce                	cmp    %ecx,%esi
  800c32:	74 1b                	je     800c4f <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c34:	39 c3                	cmp    %eax,%ebx
  800c36:	75 c4                	jne    800bfc <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c38:	8b 42 58             	mov    0x58(%edx),%eax
  800c3b:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c3e:	50                   	push   %eax
  800c3f:	56                   	push   %esi
  800c40:	68 fe 1e 80 00       	push   $0x801efe
  800c45:	e8 e4 04 00 00       	call   80112e <cprintf>
  800c4a:	83 c4 10             	add    $0x10,%esp
  800c4d:	eb ad                	jmp    800bfc <_pipeisclosed+0xe>
	}
}
  800c4f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c52:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c55:	5b                   	pop    %ebx
  800c56:	5e                   	pop    %esi
  800c57:	5f                   	pop    %edi
  800c58:	5d                   	pop    %ebp
  800c59:	c3                   	ret    

00800c5a <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c5a:	55                   	push   %ebp
  800c5b:	89 e5                	mov    %esp,%ebp
  800c5d:	57                   	push   %edi
  800c5e:	56                   	push   %esi
  800c5f:	53                   	push   %ebx
  800c60:	83 ec 28             	sub    $0x28,%esp
  800c63:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c66:	56                   	push   %esi
  800c67:	e8 16 f7 ff ff       	call   800382 <fd2data>
  800c6c:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c6e:	83 c4 10             	add    $0x10,%esp
  800c71:	bf 00 00 00 00       	mov    $0x0,%edi
  800c76:	eb 4b                	jmp    800cc3 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c78:	89 da                	mov    %ebx,%edx
  800c7a:	89 f0                	mov    %esi,%eax
  800c7c:	e8 6d ff ff ff       	call   800bee <_pipeisclosed>
  800c81:	85 c0                	test   %eax,%eax
  800c83:	75 48                	jne    800ccd <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c85:	e8 d8 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c8a:	8b 43 04             	mov    0x4(%ebx),%eax
  800c8d:	8b 0b                	mov    (%ebx),%ecx
  800c8f:	8d 51 20             	lea    0x20(%ecx),%edx
  800c92:	39 d0                	cmp    %edx,%eax
  800c94:	73 e2                	jae    800c78 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c96:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c99:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c9d:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800ca0:	89 c2                	mov    %eax,%edx
  800ca2:	c1 fa 1f             	sar    $0x1f,%edx
  800ca5:	89 d1                	mov    %edx,%ecx
  800ca7:	c1 e9 1b             	shr    $0x1b,%ecx
  800caa:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800cad:	83 e2 1f             	and    $0x1f,%edx
  800cb0:	29 ca                	sub    %ecx,%edx
  800cb2:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800cb6:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800cba:	83 c0 01             	add    $0x1,%eax
  800cbd:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc0:	83 c7 01             	add    $0x1,%edi
  800cc3:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800cc6:	75 c2                	jne    800c8a <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cc8:	8b 45 10             	mov    0x10(%ebp),%eax
  800ccb:	eb 05                	jmp    800cd2 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ccd:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cd2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cd5:	5b                   	pop    %ebx
  800cd6:	5e                   	pop    %esi
  800cd7:	5f                   	pop    %edi
  800cd8:	5d                   	pop    %ebp
  800cd9:	c3                   	ret    

00800cda <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cda:	55                   	push   %ebp
  800cdb:	89 e5                	mov    %esp,%ebp
  800cdd:	57                   	push   %edi
  800cde:	56                   	push   %esi
  800cdf:	53                   	push   %ebx
  800ce0:	83 ec 18             	sub    $0x18,%esp
  800ce3:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ce6:	57                   	push   %edi
  800ce7:	e8 96 f6 ff ff       	call   800382 <fd2data>
  800cec:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cee:	83 c4 10             	add    $0x10,%esp
  800cf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cf6:	eb 3d                	jmp    800d35 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cf8:	85 db                	test   %ebx,%ebx
  800cfa:	74 04                	je     800d00 <devpipe_read+0x26>
				return i;
  800cfc:	89 d8                	mov    %ebx,%eax
  800cfe:	eb 44                	jmp    800d44 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800d00:	89 f2                	mov    %esi,%edx
  800d02:	89 f8                	mov    %edi,%eax
  800d04:	e8 e5 fe ff ff       	call   800bee <_pipeisclosed>
  800d09:	85 c0                	test   %eax,%eax
  800d0b:	75 32                	jne    800d3f <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800d0d:	e8 50 f4 ff ff       	call   800162 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800d12:	8b 06                	mov    (%esi),%eax
  800d14:	3b 46 04             	cmp    0x4(%esi),%eax
  800d17:	74 df                	je     800cf8 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d19:	99                   	cltd   
  800d1a:	c1 ea 1b             	shr    $0x1b,%edx
  800d1d:	01 d0                	add    %edx,%eax
  800d1f:	83 e0 1f             	and    $0x1f,%eax
  800d22:	29 d0                	sub    %edx,%eax
  800d24:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d29:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d2c:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d2f:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d32:	83 c3 01             	add    $0x1,%ebx
  800d35:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d38:	75 d8                	jne    800d12 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d3a:	8b 45 10             	mov    0x10(%ebp),%eax
  800d3d:	eb 05                	jmp    800d44 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d3f:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d44:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d47:	5b                   	pop    %ebx
  800d48:	5e                   	pop    %esi
  800d49:	5f                   	pop    %edi
  800d4a:	5d                   	pop    %ebp
  800d4b:	c3                   	ret    

00800d4c <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d4c:	55                   	push   %ebp
  800d4d:	89 e5                	mov    %esp,%ebp
  800d4f:	56                   	push   %esi
  800d50:	53                   	push   %ebx
  800d51:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d54:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d57:	50                   	push   %eax
  800d58:	e8 3c f6 ff ff       	call   800399 <fd_alloc>
  800d5d:	83 c4 10             	add    $0x10,%esp
  800d60:	89 c2                	mov    %eax,%edx
  800d62:	85 c0                	test   %eax,%eax
  800d64:	0f 88 2c 01 00 00    	js     800e96 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d6a:	83 ec 04             	sub    $0x4,%esp
  800d6d:	68 07 04 00 00       	push   $0x407
  800d72:	ff 75 f4             	pushl  -0xc(%ebp)
  800d75:	6a 00                	push   $0x0
  800d77:	e8 05 f4 ff ff       	call   800181 <sys_page_alloc>
  800d7c:	83 c4 10             	add    $0x10,%esp
  800d7f:	89 c2                	mov    %eax,%edx
  800d81:	85 c0                	test   %eax,%eax
  800d83:	0f 88 0d 01 00 00    	js     800e96 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d89:	83 ec 0c             	sub    $0xc,%esp
  800d8c:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d8f:	50                   	push   %eax
  800d90:	e8 04 f6 ff ff       	call   800399 <fd_alloc>
  800d95:	89 c3                	mov    %eax,%ebx
  800d97:	83 c4 10             	add    $0x10,%esp
  800d9a:	85 c0                	test   %eax,%eax
  800d9c:	0f 88 e2 00 00 00    	js     800e84 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da2:	83 ec 04             	sub    $0x4,%esp
  800da5:	68 07 04 00 00       	push   $0x407
  800daa:	ff 75 f0             	pushl  -0x10(%ebp)
  800dad:	6a 00                	push   $0x0
  800daf:	e8 cd f3 ff ff       	call   800181 <sys_page_alloc>
  800db4:	89 c3                	mov    %eax,%ebx
  800db6:	83 c4 10             	add    $0x10,%esp
  800db9:	85 c0                	test   %eax,%eax
  800dbb:	0f 88 c3 00 00 00    	js     800e84 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800dc1:	83 ec 0c             	sub    $0xc,%esp
  800dc4:	ff 75 f4             	pushl  -0xc(%ebp)
  800dc7:	e8 b6 f5 ff ff       	call   800382 <fd2data>
  800dcc:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dce:	83 c4 0c             	add    $0xc,%esp
  800dd1:	68 07 04 00 00       	push   $0x407
  800dd6:	50                   	push   %eax
  800dd7:	6a 00                	push   $0x0
  800dd9:	e8 a3 f3 ff ff       	call   800181 <sys_page_alloc>
  800dde:	89 c3                	mov    %eax,%ebx
  800de0:	83 c4 10             	add    $0x10,%esp
  800de3:	85 c0                	test   %eax,%eax
  800de5:	0f 88 89 00 00 00    	js     800e74 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800deb:	83 ec 0c             	sub    $0xc,%esp
  800dee:	ff 75 f0             	pushl  -0x10(%ebp)
  800df1:	e8 8c f5 ff ff       	call   800382 <fd2data>
  800df6:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dfd:	50                   	push   %eax
  800dfe:	6a 00                	push   $0x0
  800e00:	56                   	push   %esi
  800e01:	6a 00                	push   $0x0
  800e03:	e8 bc f3 ff ff       	call   8001c4 <sys_page_map>
  800e08:	89 c3                	mov    %eax,%ebx
  800e0a:	83 c4 20             	add    $0x20,%esp
  800e0d:	85 c0                	test   %eax,%eax
  800e0f:	78 55                	js     800e66 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800e11:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e17:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1a:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e1c:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e1f:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e26:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e2c:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e2f:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e31:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e34:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e3b:	83 ec 0c             	sub    $0xc,%esp
  800e3e:	ff 75 f4             	pushl  -0xc(%ebp)
  800e41:	e8 2c f5 ff ff       	call   800372 <fd2num>
  800e46:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e49:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e4b:	83 c4 04             	add    $0x4,%esp
  800e4e:	ff 75 f0             	pushl  -0x10(%ebp)
  800e51:	e8 1c f5 ff ff       	call   800372 <fd2num>
  800e56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e59:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e5c:	83 c4 10             	add    $0x10,%esp
  800e5f:	ba 00 00 00 00       	mov    $0x0,%edx
  800e64:	eb 30                	jmp    800e96 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	56                   	push   %esi
  800e6a:	6a 00                	push   $0x0
  800e6c:	e8 95 f3 ff ff       	call   800206 <sys_page_unmap>
  800e71:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e74:	83 ec 08             	sub    $0x8,%esp
  800e77:	ff 75 f0             	pushl  -0x10(%ebp)
  800e7a:	6a 00                	push   $0x0
  800e7c:	e8 85 f3 ff ff       	call   800206 <sys_page_unmap>
  800e81:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e84:	83 ec 08             	sub    $0x8,%esp
  800e87:	ff 75 f4             	pushl  -0xc(%ebp)
  800e8a:	6a 00                	push   $0x0
  800e8c:	e8 75 f3 ff ff       	call   800206 <sys_page_unmap>
  800e91:	83 c4 10             	add    $0x10,%esp
  800e94:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e96:	89 d0                	mov    %edx,%eax
  800e98:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e9b:	5b                   	pop    %ebx
  800e9c:	5e                   	pop    %esi
  800e9d:	5d                   	pop    %ebp
  800e9e:	c3                   	ret    

00800e9f <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e9f:	55                   	push   %ebp
  800ea0:	89 e5                	mov    %esp,%ebp
  800ea2:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800ea5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ea8:	50                   	push   %eax
  800ea9:	ff 75 08             	pushl  0x8(%ebp)
  800eac:	e8 37 f5 ff ff       	call   8003e8 <fd_lookup>
  800eb1:	83 c4 10             	add    $0x10,%esp
  800eb4:	85 c0                	test   %eax,%eax
  800eb6:	78 18                	js     800ed0 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800eb8:	83 ec 0c             	sub    $0xc,%esp
  800ebb:	ff 75 f4             	pushl  -0xc(%ebp)
  800ebe:	e8 bf f4 ff ff       	call   800382 <fd2data>
	return _pipeisclosed(fd, p);
  800ec3:	89 c2                	mov    %eax,%edx
  800ec5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ec8:	e8 21 fd ff ff       	call   800bee <_pipeisclosed>
  800ecd:	83 c4 10             	add    $0x10,%esp
}
  800ed0:	c9                   	leave  
  800ed1:	c3                   	ret    

00800ed2 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ed2:	55                   	push   %ebp
  800ed3:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ed5:	b8 00 00 00 00       	mov    $0x0,%eax
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    

00800edc <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800edc:	55                   	push   %ebp
  800edd:	89 e5                	mov    %esp,%ebp
  800edf:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ee2:	68 16 1f 80 00       	push   $0x801f16
  800ee7:	ff 75 0c             	pushl  0xc(%ebp)
  800eea:	e8 0e 08 00 00       	call   8016fd <strcpy>
	return 0;
}
  800eef:	b8 00 00 00 00       	mov    $0x0,%eax
  800ef4:	c9                   	leave  
  800ef5:	c3                   	ret    

00800ef6 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ef6:	55                   	push   %ebp
  800ef7:	89 e5                	mov    %esp,%ebp
  800ef9:	57                   	push   %edi
  800efa:	56                   	push   %esi
  800efb:	53                   	push   %ebx
  800efc:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f02:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f07:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f0d:	eb 2d                	jmp    800f3c <devcons_write+0x46>
		m = n - tot;
  800f0f:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800f12:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800f14:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f17:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f1c:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f1f:	83 ec 04             	sub    $0x4,%esp
  800f22:	53                   	push   %ebx
  800f23:	03 45 0c             	add    0xc(%ebp),%eax
  800f26:	50                   	push   %eax
  800f27:	57                   	push   %edi
  800f28:	e8 62 09 00 00       	call   80188f <memmove>
		sys_cputs(buf, m);
  800f2d:	83 c4 08             	add    $0x8,%esp
  800f30:	53                   	push   %ebx
  800f31:	57                   	push   %edi
  800f32:	e8 8e f1 ff ff       	call   8000c5 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f37:	01 de                	add    %ebx,%esi
  800f39:	83 c4 10             	add    $0x10,%esp
  800f3c:	89 f0                	mov    %esi,%eax
  800f3e:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f41:	72 cc                	jb     800f0f <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f43:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f46:	5b                   	pop    %ebx
  800f47:	5e                   	pop    %esi
  800f48:	5f                   	pop    %edi
  800f49:	5d                   	pop    %ebp
  800f4a:	c3                   	ret    

00800f4b <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f4b:	55                   	push   %ebp
  800f4c:	89 e5                	mov    %esp,%ebp
  800f4e:	83 ec 08             	sub    $0x8,%esp
  800f51:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f56:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f5a:	74 2a                	je     800f86 <devcons_read+0x3b>
  800f5c:	eb 05                	jmp    800f63 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f5e:	e8 ff f1 ff ff       	call   800162 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f63:	e8 7b f1 ff ff       	call   8000e3 <sys_cgetc>
  800f68:	85 c0                	test   %eax,%eax
  800f6a:	74 f2                	je     800f5e <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f6c:	85 c0                	test   %eax,%eax
  800f6e:	78 16                	js     800f86 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f70:	83 f8 04             	cmp    $0x4,%eax
  800f73:	74 0c                	je     800f81 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f75:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f78:	88 02                	mov    %al,(%edx)
	return 1;
  800f7a:	b8 01 00 00 00       	mov    $0x1,%eax
  800f7f:	eb 05                	jmp    800f86 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f81:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f86:	c9                   	leave  
  800f87:	c3                   	ret    

00800f88 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f88:	55                   	push   %ebp
  800f89:	89 e5                	mov    %esp,%ebp
  800f8b:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f8e:	8b 45 08             	mov    0x8(%ebp),%eax
  800f91:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f94:	6a 01                	push   $0x1
  800f96:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f99:	50                   	push   %eax
  800f9a:	e8 26 f1 ff ff       	call   8000c5 <sys_cputs>
}
  800f9f:	83 c4 10             	add    $0x10,%esp
  800fa2:	c9                   	leave  
  800fa3:	c3                   	ret    

00800fa4 <getchar>:

int
getchar(void)
{
  800fa4:	55                   	push   %ebp
  800fa5:	89 e5                	mov    %esp,%ebp
  800fa7:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800faa:	6a 01                	push   $0x1
  800fac:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800faf:	50                   	push   %eax
  800fb0:	6a 00                	push   $0x0
  800fb2:	e8 97 f6 ff ff       	call   80064e <read>
	if (r < 0)
  800fb7:	83 c4 10             	add    $0x10,%esp
  800fba:	85 c0                	test   %eax,%eax
  800fbc:	78 0f                	js     800fcd <getchar+0x29>
		return r;
	if (r < 1)
  800fbe:	85 c0                	test   %eax,%eax
  800fc0:	7e 06                	jle    800fc8 <getchar+0x24>
		return -E_EOF;
	return c;
  800fc2:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fc6:	eb 05                	jmp    800fcd <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fc8:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fcd:	c9                   	leave  
  800fce:	c3                   	ret    

00800fcf <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fcf:	55                   	push   %ebp
  800fd0:	89 e5                	mov    %esp,%ebp
  800fd2:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fd5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fd8:	50                   	push   %eax
  800fd9:	ff 75 08             	pushl  0x8(%ebp)
  800fdc:	e8 07 f4 ff ff       	call   8003e8 <fd_lookup>
  800fe1:	83 c4 10             	add    $0x10,%esp
  800fe4:	85 c0                	test   %eax,%eax
  800fe6:	78 11                	js     800ff9 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fe8:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800feb:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800ff1:	39 10                	cmp    %edx,(%eax)
  800ff3:	0f 94 c0             	sete   %al
  800ff6:	0f b6 c0             	movzbl %al,%eax
}
  800ff9:	c9                   	leave  
  800ffa:	c3                   	ret    

00800ffb <opencons>:

int
opencons(void)
{
  800ffb:	55                   	push   %ebp
  800ffc:	89 e5                	mov    %esp,%ebp
  800ffe:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  801001:	8d 45 f4             	lea    -0xc(%ebp),%eax
  801004:	50                   	push   %eax
  801005:	e8 8f f3 ff ff       	call   800399 <fd_alloc>
  80100a:	83 c4 10             	add    $0x10,%esp
		return r;
  80100d:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  80100f:	85 c0                	test   %eax,%eax
  801011:	78 3e                	js     801051 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801013:	83 ec 04             	sub    $0x4,%esp
  801016:	68 07 04 00 00       	push   $0x407
  80101b:	ff 75 f4             	pushl  -0xc(%ebp)
  80101e:	6a 00                	push   $0x0
  801020:	e8 5c f1 ff ff       	call   800181 <sys_page_alloc>
  801025:	83 c4 10             	add    $0x10,%esp
		return r;
  801028:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80102a:	85 c0                	test   %eax,%eax
  80102c:	78 23                	js     801051 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80102e:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801034:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801037:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801039:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80103c:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801043:	83 ec 0c             	sub    $0xc,%esp
  801046:	50                   	push   %eax
  801047:	e8 26 f3 ff ff       	call   800372 <fd2num>
  80104c:	89 c2                	mov    %eax,%edx
  80104e:	83 c4 10             	add    $0x10,%esp
}
  801051:	89 d0                	mov    %edx,%eax
  801053:	c9                   	leave  
  801054:	c3                   	ret    

00801055 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801055:	55                   	push   %ebp
  801056:	89 e5                	mov    %esp,%ebp
  801058:	56                   	push   %esi
  801059:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80105a:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80105d:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801063:	e8 db f0 ff ff       	call   800143 <sys_getenvid>
  801068:	83 ec 0c             	sub    $0xc,%esp
  80106b:	ff 75 0c             	pushl  0xc(%ebp)
  80106e:	ff 75 08             	pushl  0x8(%ebp)
  801071:	56                   	push   %esi
  801072:	50                   	push   %eax
  801073:	68 24 1f 80 00       	push   $0x801f24
  801078:	e8 b1 00 00 00       	call   80112e <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80107d:	83 c4 18             	add    $0x18,%esp
  801080:	53                   	push   %ebx
  801081:	ff 75 10             	pushl  0x10(%ebp)
  801084:	e8 54 00 00 00       	call   8010dd <vcprintf>
	cprintf("\n");
  801089:	c7 04 24 0f 1f 80 00 	movl   $0x801f0f,(%esp)
  801090:	e8 99 00 00 00       	call   80112e <cprintf>
  801095:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801098:	cc                   	int3   
  801099:	eb fd                	jmp    801098 <_panic+0x43>

0080109b <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80109b:	55                   	push   %ebp
  80109c:	89 e5                	mov    %esp,%ebp
  80109e:	53                   	push   %ebx
  80109f:	83 ec 04             	sub    $0x4,%esp
  8010a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  8010a5:	8b 13                	mov    (%ebx),%edx
  8010a7:	8d 42 01             	lea    0x1(%edx),%eax
  8010aa:	89 03                	mov    %eax,(%ebx)
  8010ac:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8010af:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  8010b3:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010b8:	75 1a                	jne    8010d4 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010ba:	83 ec 08             	sub    $0x8,%esp
  8010bd:	68 ff 00 00 00       	push   $0xff
  8010c2:	8d 43 08             	lea    0x8(%ebx),%eax
  8010c5:	50                   	push   %eax
  8010c6:	e8 fa ef ff ff       	call   8000c5 <sys_cputs>
		b->idx = 0;
  8010cb:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010d1:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010d4:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010d8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010db:	c9                   	leave  
  8010dc:	c3                   	ret    

008010dd <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010dd:	55                   	push   %ebp
  8010de:	89 e5                	mov    %esp,%ebp
  8010e0:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8010e6:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ed:	00 00 00 
	b.cnt = 0;
  8010f0:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010f7:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010fa:	ff 75 0c             	pushl  0xc(%ebp)
  8010fd:	ff 75 08             	pushl  0x8(%ebp)
  801100:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  801106:	50                   	push   %eax
  801107:	68 9b 10 80 00       	push   $0x80109b
  80110c:	e8 54 01 00 00       	call   801265 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  801111:	83 c4 08             	add    $0x8,%esp
  801114:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  80111a:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801120:	50                   	push   %eax
  801121:	e8 9f ef ff ff       	call   8000c5 <sys_cputs>

	return b.cnt;
}
  801126:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80112c:	c9                   	leave  
  80112d:	c3                   	ret    

0080112e <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80112e:	55                   	push   %ebp
  80112f:	89 e5                	mov    %esp,%ebp
  801131:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801134:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801137:	50                   	push   %eax
  801138:	ff 75 08             	pushl  0x8(%ebp)
  80113b:	e8 9d ff ff ff       	call   8010dd <vcprintf>
	va_end(ap);

	return cnt;
}
  801140:	c9                   	leave  
  801141:	c3                   	ret    

00801142 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801142:	55                   	push   %ebp
  801143:	89 e5                	mov    %esp,%ebp
  801145:	57                   	push   %edi
  801146:	56                   	push   %esi
  801147:	53                   	push   %ebx
  801148:	83 ec 1c             	sub    $0x1c,%esp
  80114b:	89 c7                	mov    %eax,%edi
  80114d:	89 d6                	mov    %edx,%esi
  80114f:	8b 45 08             	mov    0x8(%ebp),%eax
  801152:	8b 55 0c             	mov    0xc(%ebp),%edx
  801155:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801158:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80115b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80115e:	bb 00 00 00 00       	mov    $0x0,%ebx
  801163:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801166:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801169:	39 d3                	cmp    %edx,%ebx
  80116b:	72 05                	jb     801172 <printnum+0x30>
  80116d:	39 45 10             	cmp    %eax,0x10(%ebp)
  801170:	77 45                	ja     8011b7 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801172:	83 ec 0c             	sub    $0xc,%esp
  801175:	ff 75 18             	pushl  0x18(%ebp)
  801178:	8b 45 14             	mov    0x14(%ebp),%eax
  80117b:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80117e:	53                   	push   %ebx
  80117f:	ff 75 10             	pushl  0x10(%ebp)
  801182:	83 ec 08             	sub    $0x8,%esp
  801185:	ff 75 e4             	pushl  -0x1c(%ebp)
  801188:	ff 75 e0             	pushl  -0x20(%ebp)
  80118b:	ff 75 dc             	pushl  -0x24(%ebp)
  80118e:	ff 75 d8             	pushl  -0x28(%ebp)
  801191:	e8 ca 09 00 00       	call   801b60 <__udivdi3>
  801196:	83 c4 18             	add    $0x18,%esp
  801199:	52                   	push   %edx
  80119a:	50                   	push   %eax
  80119b:	89 f2                	mov    %esi,%edx
  80119d:	89 f8                	mov    %edi,%eax
  80119f:	e8 9e ff ff ff       	call   801142 <printnum>
  8011a4:	83 c4 20             	add    $0x20,%esp
  8011a7:	eb 18                	jmp    8011c1 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  8011a9:	83 ec 08             	sub    $0x8,%esp
  8011ac:	56                   	push   %esi
  8011ad:	ff 75 18             	pushl  0x18(%ebp)
  8011b0:	ff d7                	call   *%edi
  8011b2:	83 c4 10             	add    $0x10,%esp
  8011b5:	eb 03                	jmp    8011ba <printnum+0x78>
  8011b7:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011ba:	83 eb 01             	sub    $0x1,%ebx
  8011bd:	85 db                	test   %ebx,%ebx
  8011bf:	7f e8                	jg     8011a9 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011c1:	83 ec 08             	sub    $0x8,%esp
  8011c4:	56                   	push   %esi
  8011c5:	83 ec 04             	sub    $0x4,%esp
  8011c8:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011cb:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ce:	ff 75 dc             	pushl  -0x24(%ebp)
  8011d1:	ff 75 d8             	pushl  -0x28(%ebp)
  8011d4:	e8 b7 0a 00 00       	call   801c90 <__umoddi3>
  8011d9:	83 c4 14             	add    $0x14,%esp
  8011dc:	0f be 80 47 1f 80 00 	movsbl 0x801f47(%eax),%eax
  8011e3:	50                   	push   %eax
  8011e4:	ff d7                	call   *%edi
}
  8011e6:	83 c4 10             	add    $0x10,%esp
  8011e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ec:	5b                   	pop    %ebx
  8011ed:	5e                   	pop    %esi
  8011ee:	5f                   	pop    %edi
  8011ef:	5d                   	pop    %ebp
  8011f0:	c3                   	ret    

008011f1 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011f1:	55                   	push   %ebp
  8011f2:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011f4:	83 fa 01             	cmp    $0x1,%edx
  8011f7:	7e 0e                	jle    801207 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011f9:	8b 10                	mov    (%eax),%edx
  8011fb:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011fe:	89 08                	mov    %ecx,(%eax)
  801200:	8b 02                	mov    (%edx),%eax
  801202:	8b 52 04             	mov    0x4(%edx),%edx
  801205:	eb 22                	jmp    801229 <getuint+0x38>
	else if (lflag)
  801207:	85 d2                	test   %edx,%edx
  801209:	74 10                	je     80121b <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  80120b:	8b 10                	mov    (%eax),%edx
  80120d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801210:	89 08                	mov    %ecx,(%eax)
  801212:	8b 02                	mov    (%edx),%eax
  801214:	ba 00 00 00 00       	mov    $0x0,%edx
  801219:	eb 0e                	jmp    801229 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  80121b:	8b 10                	mov    (%eax),%edx
  80121d:	8d 4a 04             	lea    0x4(%edx),%ecx
  801220:	89 08                	mov    %ecx,(%eax)
  801222:	8b 02                	mov    (%edx),%eax
  801224:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801229:	5d                   	pop    %ebp
  80122a:	c3                   	ret    

0080122b <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80122b:	55                   	push   %ebp
  80122c:	89 e5                	mov    %esp,%ebp
  80122e:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801231:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801235:	8b 10                	mov    (%eax),%edx
  801237:	3b 50 04             	cmp    0x4(%eax),%edx
  80123a:	73 0a                	jae    801246 <sprintputch+0x1b>
		*b->buf++ = ch;
  80123c:	8d 4a 01             	lea    0x1(%edx),%ecx
  80123f:	89 08                	mov    %ecx,(%eax)
  801241:	8b 45 08             	mov    0x8(%ebp),%eax
  801244:	88 02                	mov    %al,(%edx)
}
  801246:	5d                   	pop    %ebp
  801247:	c3                   	ret    

00801248 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801248:	55                   	push   %ebp
  801249:	89 e5                	mov    %esp,%ebp
  80124b:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80124e:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801251:	50                   	push   %eax
  801252:	ff 75 10             	pushl  0x10(%ebp)
  801255:	ff 75 0c             	pushl  0xc(%ebp)
  801258:	ff 75 08             	pushl  0x8(%ebp)
  80125b:	e8 05 00 00 00       	call   801265 <vprintfmt>
	va_end(ap);
}
  801260:	83 c4 10             	add    $0x10,%esp
  801263:	c9                   	leave  
  801264:	c3                   	ret    

00801265 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801265:	55                   	push   %ebp
  801266:	89 e5                	mov    %esp,%ebp
  801268:	57                   	push   %edi
  801269:	56                   	push   %esi
  80126a:	53                   	push   %ebx
  80126b:	83 ec 2c             	sub    $0x2c,%esp
  80126e:	8b 75 08             	mov    0x8(%ebp),%esi
  801271:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801274:	8b 7d 10             	mov    0x10(%ebp),%edi
  801277:	eb 12                	jmp    80128b <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801279:	85 c0                	test   %eax,%eax
  80127b:	0f 84 d3 03 00 00    	je     801654 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  801281:	83 ec 08             	sub    $0x8,%esp
  801284:	53                   	push   %ebx
  801285:	50                   	push   %eax
  801286:	ff d6                	call   *%esi
  801288:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80128b:	83 c7 01             	add    $0x1,%edi
  80128e:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801292:	83 f8 25             	cmp    $0x25,%eax
  801295:	75 e2                	jne    801279 <vprintfmt+0x14>
  801297:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80129b:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  8012a2:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  8012a9:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  8012b0:	ba 00 00 00 00       	mov    $0x0,%edx
  8012b5:	eb 07                	jmp    8012be <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012ba:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012be:	8d 47 01             	lea    0x1(%edi),%eax
  8012c1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012c4:	0f b6 07             	movzbl (%edi),%eax
  8012c7:	0f b6 c8             	movzbl %al,%ecx
  8012ca:	83 e8 23             	sub    $0x23,%eax
  8012cd:	3c 55                	cmp    $0x55,%al
  8012cf:	0f 87 64 03 00 00    	ja     801639 <vprintfmt+0x3d4>
  8012d5:	0f b6 c0             	movzbl %al,%eax
  8012d8:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8012df:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012e2:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012e6:	eb d6                	jmp    8012be <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012e8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012eb:	b8 00 00 00 00       	mov    $0x0,%eax
  8012f0:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012f3:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012f6:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012fa:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012fd:	8d 51 d0             	lea    -0x30(%ecx),%edx
  801300:	83 fa 09             	cmp    $0x9,%edx
  801303:	77 39                	ja     80133e <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  801305:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  801308:	eb e9                	jmp    8012f3 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  80130a:	8b 45 14             	mov    0x14(%ebp),%eax
  80130d:	8d 48 04             	lea    0x4(%eax),%ecx
  801310:	89 4d 14             	mov    %ecx,0x14(%ebp)
  801313:	8b 00                	mov    (%eax),%eax
  801315:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801318:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  80131b:	eb 27                	jmp    801344 <vprintfmt+0xdf>
  80131d:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801320:	85 c0                	test   %eax,%eax
  801322:	b9 00 00 00 00       	mov    $0x0,%ecx
  801327:	0f 49 c8             	cmovns %eax,%ecx
  80132a:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80132d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801330:	eb 8c                	jmp    8012be <vprintfmt+0x59>
  801332:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801335:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80133c:	eb 80                	jmp    8012be <vprintfmt+0x59>
  80133e:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801341:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  801344:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801348:	0f 89 70 ff ff ff    	jns    8012be <vprintfmt+0x59>
				width = precision, precision = -1;
  80134e:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801351:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801354:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80135b:	e9 5e ff ff ff       	jmp    8012be <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801360:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801363:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801366:	e9 53 ff ff ff       	jmp    8012be <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80136b:	8b 45 14             	mov    0x14(%ebp),%eax
  80136e:	8d 50 04             	lea    0x4(%eax),%edx
  801371:	89 55 14             	mov    %edx,0x14(%ebp)
  801374:	83 ec 08             	sub    $0x8,%esp
  801377:	53                   	push   %ebx
  801378:	ff 30                	pushl  (%eax)
  80137a:	ff d6                	call   *%esi
			break;
  80137c:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80137f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801382:	e9 04 ff ff ff       	jmp    80128b <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801387:	8b 45 14             	mov    0x14(%ebp),%eax
  80138a:	8d 50 04             	lea    0x4(%eax),%edx
  80138d:	89 55 14             	mov    %edx,0x14(%ebp)
  801390:	8b 00                	mov    (%eax),%eax
  801392:	99                   	cltd   
  801393:	31 d0                	xor    %edx,%eax
  801395:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801397:	83 f8 0f             	cmp    $0xf,%eax
  80139a:	7f 0b                	jg     8013a7 <vprintfmt+0x142>
  80139c:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  8013a3:	85 d2                	test   %edx,%edx
  8013a5:	75 18                	jne    8013bf <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  8013a7:	50                   	push   %eax
  8013a8:	68 5f 1f 80 00       	push   $0x801f5f
  8013ad:	53                   	push   %ebx
  8013ae:	56                   	push   %esi
  8013af:	e8 94 fe ff ff       	call   801248 <printfmt>
  8013b4:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013ba:	e9 cc fe ff ff       	jmp    80128b <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013bf:	52                   	push   %edx
  8013c0:	68 dd 1e 80 00       	push   $0x801edd
  8013c5:	53                   	push   %ebx
  8013c6:	56                   	push   %esi
  8013c7:	e8 7c fe ff ff       	call   801248 <printfmt>
  8013cc:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013d2:	e9 b4 fe ff ff       	jmp    80128b <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8013da:	8d 50 04             	lea    0x4(%eax),%edx
  8013dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8013e0:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013e2:	85 ff                	test   %edi,%edi
  8013e4:	b8 58 1f 80 00       	mov    $0x801f58,%eax
  8013e9:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013ec:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013f0:	0f 8e 94 00 00 00    	jle    80148a <vprintfmt+0x225>
  8013f6:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013fa:	0f 84 98 00 00 00    	je     801498 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  801400:	83 ec 08             	sub    $0x8,%esp
  801403:	ff 75 c8             	pushl  -0x38(%ebp)
  801406:	57                   	push   %edi
  801407:	e8 d0 02 00 00       	call   8016dc <strnlen>
  80140c:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  80140f:	29 c1                	sub    %eax,%ecx
  801411:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  801414:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801417:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  80141b:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80141e:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801421:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801423:	eb 0f                	jmp    801434 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801425:	83 ec 08             	sub    $0x8,%esp
  801428:	53                   	push   %ebx
  801429:	ff 75 e0             	pushl  -0x20(%ebp)
  80142c:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80142e:	83 ef 01             	sub    $0x1,%edi
  801431:	83 c4 10             	add    $0x10,%esp
  801434:	85 ff                	test   %edi,%edi
  801436:	7f ed                	jg     801425 <vprintfmt+0x1c0>
  801438:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80143b:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80143e:	85 c9                	test   %ecx,%ecx
  801440:	b8 00 00 00 00       	mov    $0x0,%eax
  801445:	0f 49 c1             	cmovns %ecx,%eax
  801448:	29 c1                	sub    %eax,%ecx
  80144a:	89 75 08             	mov    %esi,0x8(%ebp)
  80144d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801450:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801453:	89 cb                	mov    %ecx,%ebx
  801455:	eb 4d                	jmp    8014a4 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801457:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80145b:	74 1b                	je     801478 <vprintfmt+0x213>
  80145d:	0f be c0             	movsbl %al,%eax
  801460:	83 e8 20             	sub    $0x20,%eax
  801463:	83 f8 5e             	cmp    $0x5e,%eax
  801466:	76 10                	jbe    801478 <vprintfmt+0x213>
					putch('?', putdat);
  801468:	83 ec 08             	sub    $0x8,%esp
  80146b:	ff 75 0c             	pushl  0xc(%ebp)
  80146e:	6a 3f                	push   $0x3f
  801470:	ff 55 08             	call   *0x8(%ebp)
  801473:	83 c4 10             	add    $0x10,%esp
  801476:	eb 0d                	jmp    801485 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801478:	83 ec 08             	sub    $0x8,%esp
  80147b:	ff 75 0c             	pushl  0xc(%ebp)
  80147e:	52                   	push   %edx
  80147f:	ff 55 08             	call   *0x8(%ebp)
  801482:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801485:	83 eb 01             	sub    $0x1,%ebx
  801488:	eb 1a                	jmp    8014a4 <vprintfmt+0x23f>
  80148a:	89 75 08             	mov    %esi,0x8(%ebp)
  80148d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801490:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801493:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801496:	eb 0c                	jmp    8014a4 <vprintfmt+0x23f>
  801498:	89 75 08             	mov    %esi,0x8(%ebp)
  80149b:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80149e:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8014a1:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  8014a4:	83 c7 01             	add    $0x1,%edi
  8014a7:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  8014ab:	0f be d0             	movsbl %al,%edx
  8014ae:	85 d2                	test   %edx,%edx
  8014b0:	74 23                	je     8014d5 <vprintfmt+0x270>
  8014b2:	85 f6                	test   %esi,%esi
  8014b4:	78 a1                	js     801457 <vprintfmt+0x1f2>
  8014b6:	83 ee 01             	sub    $0x1,%esi
  8014b9:	79 9c                	jns    801457 <vprintfmt+0x1f2>
  8014bb:	89 df                	mov    %ebx,%edi
  8014bd:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c0:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c3:	eb 18                	jmp    8014dd <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014c5:	83 ec 08             	sub    $0x8,%esp
  8014c8:	53                   	push   %ebx
  8014c9:	6a 20                	push   $0x20
  8014cb:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014cd:	83 ef 01             	sub    $0x1,%edi
  8014d0:	83 c4 10             	add    $0x10,%esp
  8014d3:	eb 08                	jmp    8014dd <vprintfmt+0x278>
  8014d5:	89 df                	mov    %ebx,%edi
  8014d7:	8b 75 08             	mov    0x8(%ebp),%esi
  8014da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014dd:	85 ff                	test   %edi,%edi
  8014df:	7f e4                	jg     8014c5 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014e1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014e4:	e9 a2 fd ff ff       	jmp    80128b <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014e9:	83 fa 01             	cmp    $0x1,%edx
  8014ec:	7e 16                	jle    801504 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014ee:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f1:	8d 50 08             	lea    0x8(%eax),%edx
  8014f4:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f7:	8b 50 04             	mov    0x4(%eax),%edx
  8014fa:	8b 00                	mov    (%eax),%eax
  8014fc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8014ff:	89 55 cc             	mov    %edx,-0x34(%ebp)
  801502:	eb 32                	jmp    801536 <vprintfmt+0x2d1>
	else if (lflag)
  801504:	85 d2                	test   %edx,%edx
  801506:	74 18                	je     801520 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  801508:	8b 45 14             	mov    0x14(%ebp),%eax
  80150b:	8d 50 04             	lea    0x4(%eax),%edx
  80150e:	89 55 14             	mov    %edx,0x14(%ebp)
  801511:	8b 00                	mov    (%eax),%eax
  801513:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801516:	89 c1                	mov    %eax,%ecx
  801518:	c1 f9 1f             	sar    $0x1f,%ecx
  80151b:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  80151e:	eb 16                	jmp    801536 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801520:	8b 45 14             	mov    0x14(%ebp),%eax
  801523:	8d 50 04             	lea    0x4(%eax),%edx
  801526:	89 55 14             	mov    %edx,0x14(%ebp)
  801529:	8b 00                	mov    (%eax),%eax
  80152b:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80152e:	89 c1                	mov    %eax,%ecx
  801530:	c1 f9 1f             	sar    $0x1f,%ecx
  801533:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801536:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801539:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80153c:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80153f:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801542:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801547:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80154b:	0f 89 b0 00 00 00    	jns    801601 <vprintfmt+0x39c>
				putch('-', putdat);
  801551:	83 ec 08             	sub    $0x8,%esp
  801554:	53                   	push   %ebx
  801555:	6a 2d                	push   $0x2d
  801557:	ff d6                	call   *%esi
				num = -(long long) num;
  801559:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80155c:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80155f:	f7 d8                	neg    %eax
  801561:	83 d2 00             	adc    $0x0,%edx
  801564:	f7 da                	neg    %edx
  801566:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801569:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80156c:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80156f:	b8 0a 00 00 00       	mov    $0xa,%eax
  801574:	e9 88 00 00 00       	jmp    801601 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801579:	8d 45 14             	lea    0x14(%ebp),%eax
  80157c:	e8 70 fc ff ff       	call   8011f1 <getuint>
  801581:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801584:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  801587:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80158c:	eb 73                	jmp    801601 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80158e:	8d 45 14             	lea    0x14(%ebp),%eax
  801591:	e8 5b fc ff ff       	call   8011f1 <getuint>
  801596:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801599:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80159c:	83 ec 08             	sub    $0x8,%esp
  80159f:	53                   	push   %ebx
  8015a0:	6a 58                	push   $0x58
  8015a2:	ff d6                	call   *%esi
			putch('X', putdat);
  8015a4:	83 c4 08             	add    $0x8,%esp
  8015a7:	53                   	push   %ebx
  8015a8:	6a 58                	push   $0x58
  8015aa:	ff d6                	call   *%esi
			putch('X', putdat);
  8015ac:	83 c4 08             	add    $0x8,%esp
  8015af:	53                   	push   %ebx
  8015b0:	6a 58                	push   $0x58
  8015b2:	ff d6                	call   *%esi
			goto number;
  8015b4:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8015b7:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8015bc:	eb 43                	jmp    801601 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015be:	83 ec 08             	sub    $0x8,%esp
  8015c1:	53                   	push   %ebx
  8015c2:	6a 30                	push   $0x30
  8015c4:	ff d6                	call   *%esi
			putch('x', putdat);
  8015c6:	83 c4 08             	add    $0x8,%esp
  8015c9:	53                   	push   %ebx
  8015ca:	6a 78                	push   $0x78
  8015cc:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015ce:	8b 45 14             	mov    0x14(%ebp),%eax
  8015d1:	8d 50 04             	lea    0x4(%eax),%edx
  8015d4:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015d7:	8b 00                	mov    (%eax),%eax
  8015d9:	ba 00 00 00 00       	mov    $0x0,%edx
  8015de:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015e1:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015e4:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015e7:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015ec:	eb 13                	jmp    801601 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015ee:	8d 45 14             	lea    0x14(%ebp),%eax
  8015f1:	e8 fb fb ff ff       	call   8011f1 <getuint>
  8015f6:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015f9:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8015fc:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  801601:	83 ec 0c             	sub    $0xc,%esp
  801604:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  801608:	52                   	push   %edx
  801609:	ff 75 e0             	pushl  -0x20(%ebp)
  80160c:	50                   	push   %eax
  80160d:	ff 75 dc             	pushl  -0x24(%ebp)
  801610:	ff 75 d8             	pushl  -0x28(%ebp)
  801613:	89 da                	mov    %ebx,%edx
  801615:	89 f0                	mov    %esi,%eax
  801617:	e8 26 fb ff ff       	call   801142 <printnum>
			break;
  80161c:	83 c4 20             	add    $0x20,%esp
  80161f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801622:	e9 64 fc ff ff       	jmp    80128b <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801627:	83 ec 08             	sub    $0x8,%esp
  80162a:	53                   	push   %ebx
  80162b:	51                   	push   %ecx
  80162c:	ff d6                	call   *%esi
			break;
  80162e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801631:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801634:	e9 52 fc ff ff       	jmp    80128b <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801639:	83 ec 08             	sub    $0x8,%esp
  80163c:	53                   	push   %ebx
  80163d:	6a 25                	push   $0x25
  80163f:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801641:	83 c4 10             	add    $0x10,%esp
  801644:	eb 03                	jmp    801649 <vprintfmt+0x3e4>
  801646:	83 ef 01             	sub    $0x1,%edi
  801649:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80164d:	75 f7                	jne    801646 <vprintfmt+0x3e1>
  80164f:	e9 37 fc ff ff       	jmp    80128b <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801654:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801657:	5b                   	pop    %ebx
  801658:	5e                   	pop    %esi
  801659:	5f                   	pop    %edi
  80165a:	5d                   	pop    %ebp
  80165b:	c3                   	ret    

0080165c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80165c:	55                   	push   %ebp
  80165d:	89 e5                	mov    %esp,%ebp
  80165f:	83 ec 18             	sub    $0x18,%esp
  801662:	8b 45 08             	mov    0x8(%ebp),%eax
  801665:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801668:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80166b:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80166f:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801672:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801679:	85 c0                	test   %eax,%eax
  80167b:	74 26                	je     8016a3 <vsnprintf+0x47>
  80167d:	85 d2                	test   %edx,%edx
  80167f:	7e 22                	jle    8016a3 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801681:	ff 75 14             	pushl  0x14(%ebp)
  801684:	ff 75 10             	pushl  0x10(%ebp)
  801687:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80168a:	50                   	push   %eax
  80168b:	68 2b 12 80 00       	push   $0x80122b
  801690:	e8 d0 fb ff ff       	call   801265 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801695:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801698:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80169b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80169e:	83 c4 10             	add    $0x10,%esp
  8016a1:	eb 05                	jmp    8016a8 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  8016a3:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  8016a8:	c9                   	leave  
  8016a9:	c3                   	ret    

008016aa <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  8016aa:	55                   	push   %ebp
  8016ab:	89 e5                	mov    %esp,%ebp
  8016ad:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  8016b0:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  8016b3:	50                   	push   %eax
  8016b4:	ff 75 10             	pushl  0x10(%ebp)
  8016b7:	ff 75 0c             	pushl  0xc(%ebp)
  8016ba:	ff 75 08             	pushl  0x8(%ebp)
  8016bd:	e8 9a ff ff ff       	call   80165c <vsnprintf>
	va_end(ap);

	return rc;
}
  8016c2:	c9                   	leave  
  8016c3:	c3                   	ret    

008016c4 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016c4:	55                   	push   %ebp
  8016c5:	89 e5                	mov    %esp,%ebp
  8016c7:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ca:	b8 00 00 00 00       	mov    $0x0,%eax
  8016cf:	eb 03                	jmp    8016d4 <strlen+0x10>
		n++;
  8016d1:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016d4:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016d8:	75 f7                	jne    8016d1 <strlen+0xd>
		n++;
	return n;
}
  8016da:	5d                   	pop    %ebp
  8016db:	c3                   	ret    

008016dc <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016dc:	55                   	push   %ebp
  8016dd:	89 e5                	mov    %esp,%ebp
  8016df:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016e2:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016e5:	ba 00 00 00 00       	mov    $0x0,%edx
  8016ea:	eb 03                	jmp    8016ef <strnlen+0x13>
		n++;
  8016ec:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ef:	39 c2                	cmp    %eax,%edx
  8016f1:	74 08                	je     8016fb <strnlen+0x1f>
  8016f3:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016f7:	75 f3                	jne    8016ec <strnlen+0x10>
  8016f9:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016fb:	5d                   	pop    %ebp
  8016fc:	c3                   	ret    

008016fd <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016fd:	55                   	push   %ebp
  8016fe:	89 e5                	mov    %esp,%ebp
  801700:	53                   	push   %ebx
  801701:	8b 45 08             	mov    0x8(%ebp),%eax
  801704:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  801707:	89 c2                	mov    %eax,%edx
  801709:	83 c2 01             	add    $0x1,%edx
  80170c:	83 c1 01             	add    $0x1,%ecx
  80170f:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  801713:	88 5a ff             	mov    %bl,-0x1(%edx)
  801716:	84 db                	test   %bl,%bl
  801718:	75 ef                	jne    801709 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  80171a:	5b                   	pop    %ebx
  80171b:	5d                   	pop    %ebp
  80171c:	c3                   	ret    

0080171d <strcat>:

char *
strcat(char *dst, const char *src)
{
  80171d:	55                   	push   %ebp
  80171e:	89 e5                	mov    %esp,%ebp
  801720:	53                   	push   %ebx
  801721:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801724:	53                   	push   %ebx
  801725:	e8 9a ff ff ff       	call   8016c4 <strlen>
  80172a:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80172d:	ff 75 0c             	pushl  0xc(%ebp)
  801730:	01 d8                	add    %ebx,%eax
  801732:	50                   	push   %eax
  801733:	e8 c5 ff ff ff       	call   8016fd <strcpy>
	return dst;
}
  801738:	89 d8                	mov    %ebx,%eax
  80173a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80173d:	c9                   	leave  
  80173e:	c3                   	ret    

0080173f <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80173f:	55                   	push   %ebp
  801740:	89 e5                	mov    %esp,%ebp
  801742:	56                   	push   %esi
  801743:	53                   	push   %ebx
  801744:	8b 75 08             	mov    0x8(%ebp),%esi
  801747:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80174a:	89 f3                	mov    %esi,%ebx
  80174c:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80174f:	89 f2                	mov    %esi,%edx
  801751:	eb 0f                	jmp    801762 <strncpy+0x23>
		*dst++ = *src;
  801753:	83 c2 01             	add    $0x1,%edx
  801756:	0f b6 01             	movzbl (%ecx),%eax
  801759:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80175c:	80 39 01             	cmpb   $0x1,(%ecx)
  80175f:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801762:	39 da                	cmp    %ebx,%edx
  801764:	75 ed                	jne    801753 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801766:	89 f0                	mov    %esi,%eax
  801768:	5b                   	pop    %ebx
  801769:	5e                   	pop    %esi
  80176a:	5d                   	pop    %ebp
  80176b:	c3                   	ret    

0080176c <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80176c:	55                   	push   %ebp
  80176d:	89 e5                	mov    %esp,%ebp
  80176f:	56                   	push   %esi
  801770:	53                   	push   %ebx
  801771:	8b 75 08             	mov    0x8(%ebp),%esi
  801774:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801777:	8b 55 10             	mov    0x10(%ebp),%edx
  80177a:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80177c:	85 d2                	test   %edx,%edx
  80177e:	74 21                	je     8017a1 <strlcpy+0x35>
  801780:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801784:	89 f2                	mov    %esi,%edx
  801786:	eb 09                	jmp    801791 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801788:	83 c2 01             	add    $0x1,%edx
  80178b:	83 c1 01             	add    $0x1,%ecx
  80178e:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801791:	39 c2                	cmp    %eax,%edx
  801793:	74 09                	je     80179e <strlcpy+0x32>
  801795:	0f b6 19             	movzbl (%ecx),%ebx
  801798:	84 db                	test   %bl,%bl
  80179a:	75 ec                	jne    801788 <strlcpy+0x1c>
  80179c:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80179e:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  8017a1:	29 f0                	sub    %esi,%eax
}
  8017a3:	5b                   	pop    %ebx
  8017a4:	5e                   	pop    %esi
  8017a5:	5d                   	pop    %ebp
  8017a6:	c3                   	ret    

008017a7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  8017a7:	55                   	push   %ebp
  8017a8:	89 e5                	mov    %esp,%ebp
  8017aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8017ad:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  8017b0:	eb 06                	jmp    8017b8 <strcmp+0x11>
		p++, q++;
  8017b2:	83 c1 01             	add    $0x1,%ecx
  8017b5:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017b8:	0f b6 01             	movzbl (%ecx),%eax
  8017bb:	84 c0                	test   %al,%al
  8017bd:	74 04                	je     8017c3 <strcmp+0x1c>
  8017bf:	3a 02                	cmp    (%edx),%al
  8017c1:	74 ef                	je     8017b2 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017c3:	0f b6 c0             	movzbl %al,%eax
  8017c6:	0f b6 12             	movzbl (%edx),%edx
  8017c9:	29 d0                	sub    %edx,%eax
}
  8017cb:	5d                   	pop    %ebp
  8017cc:	c3                   	ret    

008017cd <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017cd:	55                   	push   %ebp
  8017ce:	89 e5                	mov    %esp,%ebp
  8017d0:	53                   	push   %ebx
  8017d1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017d4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017d7:	89 c3                	mov    %eax,%ebx
  8017d9:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017dc:	eb 06                	jmp    8017e4 <strncmp+0x17>
		n--, p++, q++;
  8017de:	83 c0 01             	add    $0x1,%eax
  8017e1:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017e4:	39 d8                	cmp    %ebx,%eax
  8017e6:	74 15                	je     8017fd <strncmp+0x30>
  8017e8:	0f b6 08             	movzbl (%eax),%ecx
  8017eb:	84 c9                	test   %cl,%cl
  8017ed:	74 04                	je     8017f3 <strncmp+0x26>
  8017ef:	3a 0a                	cmp    (%edx),%cl
  8017f1:	74 eb                	je     8017de <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017f3:	0f b6 00             	movzbl (%eax),%eax
  8017f6:	0f b6 12             	movzbl (%edx),%edx
  8017f9:	29 d0                	sub    %edx,%eax
  8017fb:	eb 05                	jmp    801802 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017fd:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  801802:	5b                   	pop    %ebx
  801803:	5d                   	pop    %ebp
  801804:	c3                   	ret    

00801805 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  801805:	55                   	push   %ebp
  801806:	89 e5                	mov    %esp,%ebp
  801808:	8b 45 08             	mov    0x8(%ebp),%eax
  80180b:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180f:	eb 07                	jmp    801818 <strchr+0x13>
		if (*s == c)
  801811:	38 ca                	cmp    %cl,%dl
  801813:	74 0f                	je     801824 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  801815:	83 c0 01             	add    $0x1,%eax
  801818:	0f b6 10             	movzbl (%eax),%edx
  80181b:	84 d2                	test   %dl,%dl
  80181d:	75 f2                	jne    801811 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  80181f:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801824:	5d                   	pop    %ebp
  801825:	c3                   	ret    

00801826 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801826:	55                   	push   %ebp
  801827:	89 e5                	mov    %esp,%ebp
  801829:	8b 45 08             	mov    0x8(%ebp),%eax
  80182c:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801830:	eb 03                	jmp    801835 <strfind+0xf>
  801832:	83 c0 01             	add    $0x1,%eax
  801835:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801838:	38 ca                	cmp    %cl,%dl
  80183a:	74 04                	je     801840 <strfind+0x1a>
  80183c:	84 d2                	test   %dl,%dl
  80183e:	75 f2                	jne    801832 <strfind+0xc>
			break;
	return (char *) s;
}
  801840:	5d                   	pop    %ebp
  801841:	c3                   	ret    

00801842 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801842:	55                   	push   %ebp
  801843:	89 e5                	mov    %esp,%ebp
  801845:	57                   	push   %edi
  801846:	56                   	push   %esi
  801847:	53                   	push   %ebx
  801848:	8b 7d 08             	mov    0x8(%ebp),%edi
  80184b:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80184e:	85 c9                	test   %ecx,%ecx
  801850:	74 36                	je     801888 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801852:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801858:	75 28                	jne    801882 <memset+0x40>
  80185a:	f6 c1 03             	test   $0x3,%cl
  80185d:	75 23                	jne    801882 <memset+0x40>
		c &= 0xFF;
  80185f:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801863:	89 d3                	mov    %edx,%ebx
  801865:	c1 e3 08             	shl    $0x8,%ebx
  801868:	89 d6                	mov    %edx,%esi
  80186a:	c1 e6 18             	shl    $0x18,%esi
  80186d:	89 d0                	mov    %edx,%eax
  80186f:	c1 e0 10             	shl    $0x10,%eax
  801872:	09 f0                	or     %esi,%eax
  801874:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801876:	89 d8                	mov    %ebx,%eax
  801878:	09 d0                	or     %edx,%eax
  80187a:	c1 e9 02             	shr    $0x2,%ecx
  80187d:	fc                   	cld    
  80187e:	f3 ab                	rep stos %eax,%es:(%edi)
  801880:	eb 06                	jmp    801888 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801882:	8b 45 0c             	mov    0xc(%ebp),%eax
  801885:	fc                   	cld    
  801886:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801888:	89 f8                	mov    %edi,%eax
  80188a:	5b                   	pop    %ebx
  80188b:	5e                   	pop    %esi
  80188c:	5f                   	pop    %edi
  80188d:	5d                   	pop    %ebp
  80188e:	c3                   	ret    

0080188f <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80188f:	55                   	push   %ebp
  801890:	89 e5                	mov    %esp,%ebp
  801892:	57                   	push   %edi
  801893:	56                   	push   %esi
  801894:	8b 45 08             	mov    0x8(%ebp),%eax
  801897:	8b 75 0c             	mov    0xc(%ebp),%esi
  80189a:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80189d:	39 c6                	cmp    %eax,%esi
  80189f:	73 35                	jae    8018d6 <memmove+0x47>
  8018a1:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  8018a4:	39 d0                	cmp    %edx,%eax
  8018a6:	73 2e                	jae    8018d6 <memmove+0x47>
		s += n;
		d += n;
  8018a8:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018ab:	89 d6                	mov    %edx,%esi
  8018ad:	09 fe                	or     %edi,%esi
  8018af:	f7 c6 03 00 00 00    	test   $0x3,%esi
  8018b5:	75 13                	jne    8018ca <memmove+0x3b>
  8018b7:	f6 c1 03             	test   $0x3,%cl
  8018ba:	75 0e                	jne    8018ca <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018bc:	83 ef 04             	sub    $0x4,%edi
  8018bf:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018c2:	c1 e9 02             	shr    $0x2,%ecx
  8018c5:	fd                   	std    
  8018c6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c8:	eb 09                	jmp    8018d3 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018ca:	83 ef 01             	sub    $0x1,%edi
  8018cd:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018d0:	fd                   	std    
  8018d1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018d3:	fc                   	cld    
  8018d4:	eb 1d                	jmp    8018f3 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018d6:	89 f2                	mov    %esi,%edx
  8018d8:	09 c2                	or     %eax,%edx
  8018da:	f6 c2 03             	test   $0x3,%dl
  8018dd:	75 0f                	jne    8018ee <memmove+0x5f>
  8018df:	f6 c1 03             	test   $0x3,%cl
  8018e2:	75 0a                	jne    8018ee <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018e4:	c1 e9 02             	shr    $0x2,%ecx
  8018e7:	89 c7                	mov    %eax,%edi
  8018e9:	fc                   	cld    
  8018ea:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ec:	eb 05                	jmp    8018f3 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018ee:	89 c7                	mov    %eax,%edi
  8018f0:	fc                   	cld    
  8018f1:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018f3:	5e                   	pop    %esi
  8018f4:	5f                   	pop    %edi
  8018f5:	5d                   	pop    %ebp
  8018f6:	c3                   	ret    

008018f7 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018f7:	55                   	push   %ebp
  8018f8:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018fa:	ff 75 10             	pushl  0x10(%ebp)
  8018fd:	ff 75 0c             	pushl  0xc(%ebp)
  801900:	ff 75 08             	pushl  0x8(%ebp)
  801903:	e8 87 ff ff ff       	call   80188f <memmove>
}
  801908:	c9                   	leave  
  801909:	c3                   	ret    

0080190a <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  80190a:	55                   	push   %ebp
  80190b:	89 e5                	mov    %esp,%ebp
  80190d:	56                   	push   %esi
  80190e:	53                   	push   %ebx
  80190f:	8b 45 08             	mov    0x8(%ebp),%eax
  801912:	8b 55 0c             	mov    0xc(%ebp),%edx
  801915:	89 c6                	mov    %eax,%esi
  801917:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80191a:	eb 1a                	jmp    801936 <memcmp+0x2c>
		if (*s1 != *s2)
  80191c:	0f b6 08             	movzbl (%eax),%ecx
  80191f:	0f b6 1a             	movzbl (%edx),%ebx
  801922:	38 d9                	cmp    %bl,%cl
  801924:	74 0a                	je     801930 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801926:	0f b6 c1             	movzbl %cl,%eax
  801929:	0f b6 db             	movzbl %bl,%ebx
  80192c:	29 d8                	sub    %ebx,%eax
  80192e:	eb 0f                	jmp    80193f <memcmp+0x35>
		s1++, s2++;
  801930:	83 c0 01             	add    $0x1,%eax
  801933:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801936:	39 f0                	cmp    %esi,%eax
  801938:	75 e2                	jne    80191c <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80193a:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80193f:	5b                   	pop    %ebx
  801940:	5e                   	pop    %esi
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    

00801943 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	53                   	push   %ebx
  801947:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80194a:	89 c1                	mov    %eax,%ecx
  80194c:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80194f:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801953:	eb 0a                	jmp    80195f <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801955:	0f b6 10             	movzbl (%eax),%edx
  801958:	39 da                	cmp    %ebx,%edx
  80195a:	74 07                	je     801963 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80195c:	83 c0 01             	add    $0x1,%eax
  80195f:	39 c8                	cmp    %ecx,%eax
  801961:	72 f2                	jb     801955 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801963:	5b                   	pop    %ebx
  801964:	5d                   	pop    %ebp
  801965:	c3                   	ret    

00801966 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801966:	55                   	push   %ebp
  801967:	89 e5                	mov    %esp,%ebp
  801969:	57                   	push   %edi
  80196a:	56                   	push   %esi
  80196b:	53                   	push   %ebx
  80196c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80196f:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801972:	eb 03                	jmp    801977 <strtol+0x11>
		s++;
  801974:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801977:	0f b6 01             	movzbl (%ecx),%eax
  80197a:	3c 20                	cmp    $0x20,%al
  80197c:	74 f6                	je     801974 <strtol+0xe>
  80197e:	3c 09                	cmp    $0x9,%al
  801980:	74 f2                	je     801974 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801982:	3c 2b                	cmp    $0x2b,%al
  801984:	75 0a                	jne    801990 <strtol+0x2a>
		s++;
  801986:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801989:	bf 00 00 00 00       	mov    $0x0,%edi
  80198e:	eb 11                	jmp    8019a1 <strtol+0x3b>
  801990:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801995:	3c 2d                	cmp    $0x2d,%al
  801997:	75 08                	jne    8019a1 <strtol+0x3b>
		s++, neg = 1;
  801999:	83 c1 01             	add    $0x1,%ecx
  80199c:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  8019a1:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  8019a7:	75 15                	jne    8019be <strtol+0x58>
  8019a9:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ac:	75 10                	jne    8019be <strtol+0x58>
  8019ae:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  8019b2:	75 7c                	jne    801a30 <strtol+0xca>
		s += 2, base = 16;
  8019b4:	83 c1 02             	add    $0x2,%ecx
  8019b7:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019bc:	eb 16                	jmp    8019d4 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019be:	85 db                	test   %ebx,%ebx
  8019c0:	75 12                	jne    8019d4 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019c2:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019c7:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ca:	75 08                	jne    8019d4 <strtol+0x6e>
		s++, base = 8;
  8019cc:	83 c1 01             	add    $0x1,%ecx
  8019cf:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8019d9:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019dc:	0f b6 11             	movzbl (%ecx),%edx
  8019df:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019e2:	89 f3                	mov    %esi,%ebx
  8019e4:	80 fb 09             	cmp    $0x9,%bl
  8019e7:	77 08                	ja     8019f1 <strtol+0x8b>
			dig = *s - '0';
  8019e9:	0f be d2             	movsbl %dl,%edx
  8019ec:	83 ea 30             	sub    $0x30,%edx
  8019ef:	eb 22                	jmp    801a13 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019f1:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019f4:	89 f3                	mov    %esi,%ebx
  8019f6:	80 fb 19             	cmp    $0x19,%bl
  8019f9:	77 08                	ja     801a03 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019fb:	0f be d2             	movsbl %dl,%edx
  8019fe:	83 ea 57             	sub    $0x57,%edx
  801a01:	eb 10                	jmp    801a13 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  801a03:	8d 72 bf             	lea    -0x41(%edx),%esi
  801a06:	89 f3                	mov    %esi,%ebx
  801a08:	80 fb 19             	cmp    $0x19,%bl
  801a0b:	77 16                	ja     801a23 <strtol+0xbd>
			dig = *s - 'A' + 10;
  801a0d:	0f be d2             	movsbl %dl,%edx
  801a10:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  801a13:	3b 55 10             	cmp    0x10(%ebp),%edx
  801a16:	7d 0b                	jge    801a23 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a18:	83 c1 01             	add    $0x1,%ecx
  801a1b:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a1f:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a21:	eb b9                	jmp    8019dc <strtol+0x76>

	if (endptr)
  801a23:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a27:	74 0d                	je     801a36 <strtol+0xd0>
		*endptr = (char *) s;
  801a29:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a2c:	89 0e                	mov    %ecx,(%esi)
  801a2e:	eb 06                	jmp    801a36 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a30:	85 db                	test   %ebx,%ebx
  801a32:	74 98                	je     8019cc <strtol+0x66>
  801a34:	eb 9e                	jmp    8019d4 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a36:	89 c2                	mov    %eax,%edx
  801a38:	f7 da                	neg    %edx
  801a3a:	85 ff                	test   %edi,%edi
  801a3c:	0f 45 c2             	cmovne %edx,%eax
}
  801a3f:	5b                   	pop    %ebx
  801a40:	5e                   	pop    %esi
  801a41:	5f                   	pop    %edi
  801a42:	5d                   	pop    %ebp
  801a43:	c3                   	ret    

00801a44 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a44:	55                   	push   %ebp
  801a45:	89 e5                	mov    %esp,%ebp
  801a47:	56                   	push   %esi
  801a48:	53                   	push   %ebx
  801a49:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a4c:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	ff 75 0c             	pushl  0xc(%ebp)
  801a55:	e8 d7 e8 ff ff       	call   800331 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801a5a:	83 c4 10             	add    $0x10,%esp
  801a5d:	85 f6                	test   %esi,%esi
  801a5f:	74 1c                	je     801a7d <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801a61:	a1 04 40 80 00       	mov    0x804004,%eax
  801a66:	8b 40 78             	mov    0x78(%eax),%eax
  801a69:	89 06                	mov    %eax,(%esi)
  801a6b:	eb 10                	jmp    801a7d <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801a6d:	83 ec 0c             	sub    $0xc,%esp
  801a70:	68 40 22 80 00       	push   $0x802240
  801a75:	e8 b4 f6 ff ff       	call   80112e <cprintf>
  801a7a:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801a7d:	a1 04 40 80 00       	mov    0x804004,%eax
  801a82:	8b 50 74             	mov    0x74(%eax),%edx
  801a85:	85 d2                	test   %edx,%edx
  801a87:	74 e4                	je     801a6d <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801a89:	85 db                	test   %ebx,%ebx
  801a8b:	74 05                	je     801a92 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801a8d:	8b 40 74             	mov    0x74(%eax),%eax
  801a90:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a92:	a1 04 40 80 00       	mov    0x804004,%eax
  801a97:	8b 40 70             	mov    0x70(%eax),%eax

}
  801a9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a9d:	5b                   	pop    %ebx
  801a9e:	5e                   	pop    %esi
  801a9f:	5d                   	pop    %ebp
  801aa0:	c3                   	ret    

00801aa1 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801aa1:	55                   	push   %ebp
  801aa2:	89 e5                	mov    %esp,%ebp
  801aa4:	57                   	push   %edi
  801aa5:	56                   	push   %esi
  801aa6:	53                   	push   %ebx
  801aa7:	83 ec 0c             	sub    $0xc,%esp
  801aaa:	8b 7d 08             	mov    0x8(%ebp),%edi
  801aad:	8b 75 0c             	mov    0xc(%ebp),%esi
  801ab0:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801ab3:	85 db                	test   %ebx,%ebx
  801ab5:	75 13                	jne    801aca <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801ab7:	6a 00                	push   $0x0
  801ab9:	68 00 00 c0 ee       	push   $0xeec00000
  801abe:	56                   	push   %esi
  801abf:	57                   	push   %edi
  801ac0:	e8 49 e8 ff ff       	call   80030e <sys_ipc_try_send>
  801ac5:	83 c4 10             	add    $0x10,%esp
  801ac8:	eb 0e                	jmp    801ad8 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801aca:	ff 75 14             	pushl  0x14(%ebp)
  801acd:	53                   	push   %ebx
  801ace:	56                   	push   %esi
  801acf:	57                   	push   %edi
  801ad0:	e8 39 e8 ff ff       	call   80030e <sys_ipc_try_send>
  801ad5:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801ad8:	85 c0                	test   %eax,%eax
  801ada:	75 d7                	jne    801ab3 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801adc:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801adf:	5b                   	pop    %ebx
  801ae0:	5e                   	pop    %esi
  801ae1:	5f                   	pop    %edi
  801ae2:	5d                   	pop    %ebp
  801ae3:	c3                   	ret    

00801ae4 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ae4:	55                   	push   %ebp
  801ae5:	89 e5                	mov    %esp,%ebp
  801ae7:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801aea:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801aef:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801af2:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801af8:	8b 52 50             	mov    0x50(%edx),%edx
  801afb:	39 ca                	cmp    %ecx,%edx
  801afd:	75 0d                	jne    801b0c <ipc_find_env+0x28>
			return envs[i].env_id;
  801aff:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801b02:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801b07:	8b 40 48             	mov    0x48(%eax),%eax
  801b0a:	eb 0f                	jmp    801b1b <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801b0c:	83 c0 01             	add    $0x1,%eax
  801b0f:	3d 00 04 00 00       	cmp    $0x400,%eax
  801b14:	75 d9                	jne    801aef <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801b16:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b1b:	5d                   	pop    %ebp
  801b1c:	c3                   	ret    

00801b1d <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b1d:	55                   	push   %ebp
  801b1e:	89 e5                	mov    %esp,%ebp
  801b20:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b23:	89 d0                	mov    %edx,%eax
  801b25:	c1 e8 16             	shr    $0x16,%eax
  801b28:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b2f:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b34:	f6 c1 01             	test   $0x1,%cl
  801b37:	74 1d                	je     801b56 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b39:	c1 ea 0c             	shr    $0xc,%edx
  801b3c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b43:	f6 c2 01             	test   $0x1,%dl
  801b46:	74 0e                	je     801b56 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b48:	c1 ea 0c             	shr    $0xc,%edx
  801b4b:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b52:	ef 
  801b53:	0f b7 c0             	movzwl %ax,%eax
}
  801b56:	5d                   	pop    %ebp
  801b57:	c3                   	ret    
  801b58:	66 90                	xchg   %ax,%ax
  801b5a:	66 90                	xchg   %ax,%ax
  801b5c:	66 90                	xchg   %ax,%ax
  801b5e:	66 90                	xchg   %ax,%ax

00801b60 <__udivdi3>:
  801b60:	55                   	push   %ebp
  801b61:	57                   	push   %edi
  801b62:	56                   	push   %esi
  801b63:	53                   	push   %ebx
  801b64:	83 ec 1c             	sub    $0x1c,%esp
  801b67:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b6b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b6f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b73:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b77:	85 f6                	test   %esi,%esi
  801b79:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b7d:	89 ca                	mov    %ecx,%edx
  801b7f:	89 f8                	mov    %edi,%eax
  801b81:	75 3d                	jne    801bc0 <__udivdi3+0x60>
  801b83:	39 cf                	cmp    %ecx,%edi
  801b85:	0f 87 c5 00 00 00    	ja     801c50 <__udivdi3+0xf0>
  801b8b:	85 ff                	test   %edi,%edi
  801b8d:	89 fd                	mov    %edi,%ebp
  801b8f:	75 0b                	jne    801b9c <__udivdi3+0x3c>
  801b91:	b8 01 00 00 00       	mov    $0x1,%eax
  801b96:	31 d2                	xor    %edx,%edx
  801b98:	f7 f7                	div    %edi
  801b9a:	89 c5                	mov    %eax,%ebp
  801b9c:	89 c8                	mov    %ecx,%eax
  801b9e:	31 d2                	xor    %edx,%edx
  801ba0:	f7 f5                	div    %ebp
  801ba2:	89 c1                	mov    %eax,%ecx
  801ba4:	89 d8                	mov    %ebx,%eax
  801ba6:	89 cf                	mov    %ecx,%edi
  801ba8:	f7 f5                	div    %ebp
  801baa:	89 c3                	mov    %eax,%ebx
  801bac:	89 d8                	mov    %ebx,%eax
  801bae:	89 fa                	mov    %edi,%edx
  801bb0:	83 c4 1c             	add    $0x1c,%esp
  801bb3:	5b                   	pop    %ebx
  801bb4:	5e                   	pop    %esi
  801bb5:	5f                   	pop    %edi
  801bb6:	5d                   	pop    %ebp
  801bb7:	c3                   	ret    
  801bb8:	90                   	nop
  801bb9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bc0:	39 ce                	cmp    %ecx,%esi
  801bc2:	77 74                	ja     801c38 <__udivdi3+0xd8>
  801bc4:	0f bd fe             	bsr    %esi,%edi
  801bc7:	83 f7 1f             	xor    $0x1f,%edi
  801bca:	0f 84 98 00 00 00    	je     801c68 <__udivdi3+0x108>
  801bd0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bd5:	89 f9                	mov    %edi,%ecx
  801bd7:	89 c5                	mov    %eax,%ebp
  801bd9:	29 fb                	sub    %edi,%ebx
  801bdb:	d3 e6                	shl    %cl,%esi
  801bdd:	89 d9                	mov    %ebx,%ecx
  801bdf:	d3 ed                	shr    %cl,%ebp
  801be1:	89 f9                	mov    %edi,%ecx
  801be3:	d3 e0                	shl    %cl,%eax
  801be5:	09 ee                	or     %ebp,%esi
  801be7:	89 d9                	mov    %ebx,%ecx
  801be9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bed:	89 d5                	mov    %edx,%ebp
  801bef:	8b 44 24 08          	mov    0x8(%esp),%eax
  801bf3:	d3 ed                	shr    %cl,%ebp
  801bf5:	89 f9                	mov    %edi,%ecx
  801bf7:	d3 e2                	shl    %cl,%edx
  801bf9:	89 d9                	mov    %ebx,%ecx
  801bfb:	d3 e8                	shr    %cl,%eax
  801bfd:	09 c2                	or     %eax,%edx
  801bff:	89 d0                	mov    %edx,%eax
  801c01:	89 ea                	mov    %ebp,%edx
  801c03:	f7 f6                	div    %esi
  801c05:	89 d5                	mov    %edx,%ebp
  801c07:	89 c3                	mov    %eax,%ebx
  801c09:	f7 64 24 0c          	mull   0xc(%esp)
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	72 10                	jb     801c21 <__udivdi3+0xc1>
  801c11:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c15:	89 f9                	mov    %edi,%ecx
  801c17:	d3 e6                	shl    %cl,%esi
  801c19:	39 c6                	cmp    %eax,%esi
  801c1b:	73 07                	jae    801c24 <__udivdi3+0xc4>
  801c1d:	39 d5                	cmp    %edx,%ebp
  801c1f:	75 03                	jne    801c24 <__udivdi3+0xc4>
  801c21:	83 eb 01             	sub    $0x1,%ebx
  801c24:	31 ff                	xor    %edi,%edi
  801c26:	89 d8                	mov    %ebx,%eax
  801c28:	89 fa                	mov    %edi,%edx
  801c2a:	83 c4 1c             	add    $0x1c,%esp
  801c2d:	5b                   	pop    %ebx
  801c2e:	5e                   	pop    %esi
  801c2f:	5f                   	pop    %edi
  801c30:	5d                   	pop    %ebp
  801c31:	c3                   	ret    
  801c32:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c38:	31 ff                	xor    %edi,%edi
  801c3a:	31 db                	xor    %ebx,%ebx
  801c3c:	89 d8                	mov    %ebx,%eax
  801c3e:	89 fa                	mov    %edi,%edx
  801c40:	83 c4 1c             	add    $0x1c,%esp
  801c43:	5b                   	pop    %ebx
  801c44:	5e                   	pop    %esi
  801c45:	5f                   	pop    %edi
  801c46:	5d                   	pop    %ebp
  801c47:	c3                   	ret    
  801c48:	90                   	nop
  801c49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c50:	89 d8                	mov    %ebx,%eax
  801c52:	f7 f7                	div    %edi
  801c54:	31 ff                	xor    %edi,%edi
  801c56:	89 c3                	mov    %eax,%ebx
  801c58:	89 d8                	mov    %ebx,%eax
  801c5a:	89 fa                	mov    %edi,%edx
  801c5c:	83 c4 1c             	add    $0x1c,%esp
  801c5f:	5b                   	pop    %ebx
  801c60:	5e                   	pop    %esi
  801c61:	5f                   	pop    %edi
  801c62:	5d                   	pop    %ebp
  801c63:	c3                   	ret    
  801c64:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c68:	39 ce                	cmp    %ecx,%esi
  801c6a:	72 0c                	jb     801c78 <__udivdi3+0x118>
  801c6c:	31 db                	xor    %ebx,%ebx
  801c6e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c72:	0f 87 34 ff ff ff    	ja     801bac <__udivdi3+0x4c>
  801c78:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c7d:	e9 2a ff ff ff       	jmp    801bac <__udivdi3+0x4c>
  801c82:	66 90                	xchg   %ax,%ax
  801c84:	66 90                	xchg   %ax,%ax
  801c86:	66 90                	xchg   %ax,%ax
  801c88:	66 90                	xchg   %ax,%ax
  801c8a:	66 90                	xchg   %ax,%ax
  801c8c:	66 90                	xchg   %ax,%ax
  801c8e:	66 90                	xchg   %ax,%ax

00801c90 <__umoddi3>:
  801c90:	55                   	push   %ebp
  801c91:	57                   	push   %edi
  801c92:	56                   	push   %esi
  801c93:	53                   	push   %ebx
  801c94:	83 ec 1c             	sub    $0x1c,%esp
  801c97:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c9b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c9f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801ca3:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801ca7:	85 d2                	test   %edx,%edx
  801ca9:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801cad:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801cb1:	89 f3                	mov    %esi,%ebx
  801cb3:	89 3c 24             	mov    %edi,(%esp)
  801cb6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801cba:	75 1c                	jne    801cd8 <__umoddi3+0x48>
  801cbc:	39 f7                	cmp    %esi,%edi
  801cbe:	76 50                	jbe    801d10 <__umoddi3+0x80>
  801cc0:	89 c8                	mov    %ecx,%eax
  801cc2:	89 f2                	mov    %esi,%edx
  801cc4:	f7 f7                	div    %edi
  801cc6:	89 d0                	mov    %edx,%eax
  801cc8:	31 d2                	xor    %edx,%edx
  801cca:	83 c4 1c             	add    $0x1c,%esp
  801ccd:	5b                   	pop    %ebx
  801cce:	5e                   	pop    %esi
  801ccf:	5f                   	pop    %edi
  801cd0:	5d                   	pop    %ebp
  801cd1:	c3                   	ret    
  801cd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cd8:	39 f2                	cmp    %esi,%edx
  801cda:	89 d0                	mov    %edx,%eax
  801cdc:	77 52                	ja     801d30 <__umoddi3+0xa0>
  801cde:	0f bd ea             	bsr    %edx,%ebp
  801ce1:	83 f5 1f             	xor    $0x1f,%ebp
  801ce4:	75 5a                	jne    801d40 <__umoddi3+0xb0>
  801ce6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cea:	0f 82 e0 00 00 00    	jb     801dd0 <__umoddi3+0x140>
  801cf0:	39 0c 24             	cmp    %ecx,(%esp)
  801cf3:	0f 86 d7 00 00 00    	jbe    801dd0 <__umoddi3+0x140>
  801cf9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801cfd:	8b 54 24 04          	mov    0x4(%esp),%edx
  801d01:	83 c4 1c             	add    $0x1c,%esp
  801d04:	5b                   	pop    %ebx
  801d05:	5e                   	pop    %esi
  801d06:	5f                   	pop    %edi
  801d07:	5d                   	pop    %ebp
  801d08:	c3                   	ret    
  801d09:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d10:	85 ff                	test   %edi,%edi
  801d12:	89 fd                	mov    %edi,%ebp
  801d14:	75 0b                	jne    801d21 <__umoddi3+0x91>
  801d16:	b8 01 00 00 00       	mov    $0x1,%eax
  801d1b:	31 d2                	xor    %edx,%edx
  801d1d:	f7 f7                	div    %edi
  801d1f:	89 c5                	mov    %eax,%ebp
  801d21:	89 f0                	mov    %esi,%eax
  801d23:	31 d2                	xor    %edx,%edx
  801d25:	f7 f5                	div    %ebp
  801d27:	89 c8                	mov    %ecx,%eax
  801d29:	f7 f5                	div    %ebp
  801d2b:	89 d0                	mov    %edx,%eax
  801d2d:	eb 99                	jmp    801cc8 <__umoddi3+0x38>
  801d2f:	90                   	nop
  801d30:	89 c8                	mov    %ecx,%eax
  801d32:	89 f2                	mov    %esi,%edx
  801d34:	83 c4 1c             	add    $0x1c,%esp
  801d37:	5b                   	pop    %ebx
  801d38:	5e                   	pop    %esi
  801d39:	5f                   	pop    %edi
  801d3a:	5d                   	pop    %ebp
  801d3b:	c3                   	ret    
  801d3c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d40:	8b 34 24             	mov    (%esp),%esi
  801d43:	bf 20 00 00 00       	mov    $0x20,%edi
  801d48:	89 e9                	mov    %ebp,%ecx
  801d4a:	29 ef                	sub    %ebp,%edi
  801d4c:	d3 e0                	shl    %cl,%eax
  801d4e:	89 f9                	mov    %edi,%ecx
  801d50:	89 f2                	mov    %esi,%edx
  801d52:	d3 ea                	shr    %cl,%edx
  801d54:	89 e9                	mov    %ebp,%ecx
  801d56:	09 c2                	or     %eax,%edx
  801d58:	89 d8                	mov    %ebx,%eax
  801d5a:	89 14 24             	mov    %edx,(%esp)
  801d5d:	89 f2                	mov    %esi,%edx
  801d5f:	d3 e2                	shl    %cl,%edx
  801d61:	89 f9                	mov    %edi,%ecx
  801d63:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d67:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d6b:	d3 e8                	shr    %cl,%eax
  801d6d:	89 e9                	mov    %ebp,%ecx
  801d6f:	89 c6                	mov    %eax,%esi
  801d71:	d3 e3                	shl    %cl,%ebx
  801d73:	89 f9                	mov    %edi,%ecx
  801d75:	89 d0                	mov    %edx,%eax
  801d77:	d3 e8                	shr    %cl,%eax
  801d79:	89 e9                	mov    %ebp,%ecx
  801d7b:	09 d8                	or     %ebx,%eax
  801d7d:	89 d3                	mov    %edx,%ebx
  801d7f:	89 f2                	mov    %esi,%edx
  801d81:	f7 34 24             	divl   (%esp)
  801d84:	89 d6                	mov    %edx,%esi
  801d86:	d3 e3                	shl    %cl,%ebx
  801d88:	f7 64 24 04          	mull   0x4(%esp)
  801d8c:	39 d6                	cmp    %edx,%esi
  801d8e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d92:	89 d1                	mov    %edx,%ecx
  801d94:	89 c3                	mov    %eax,%ebx
  801d96:	72 08                	jb     801da0 <__umoddi3+0x110>
  801d98:	75 11                	jne    801dab <__umoddi3+0x11b>
  801d9a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d9e:	73 0b                	jae    801dab <__umoddi3+0x11b>
  801da0:	2b 44 24 04          	sub    0x4(%esp),%eax
  801da4:	1b 14 24             	sbb    (%esp),%edx
  801da7:	89 d1                	mov    %edx,%ecx
  801da9:	89 c3                	mov    %eax,%ebx
  801dab:	8b 54 24 08          	mov    0x8(%esp),%edx
  801daf:	29 da                	sub    %ebx,%edx
  801db1:	19 ce                	sbb    %ecx,%esi
  801db3:	89 f9                	mov    %edi,%ecx
  801db5:	89 f0                	mov    %esi,%eax
  801db7:	d3 e0                	shl    %cl,%eax
  801db9:	89 e9                	mov    %ebp,%ecx
  801dbb:	d3 ea                	shr    %cl,%edx
  801dbd:	89 e9                	mov    %ebp,%ecx
  801dbf:	d3 ee                	shr    %cl,%esi
  801dc1:	09 d0                	or     %edx,%eax
  801dc3:	89 f2                	mov    %esi,%edx
  801dc5:	83 c4 1c             	add    $0x1c,%esp
  801dc8:	5b                   	pop    %ebx
  801dc9:	5e                   	pop    %esi
  801dca:	5f                   	pop    %edi
  801dcb:	5d                   	pop    %ebp
  801dcc:	c3                   	ret    
  801dcd:	8d 76 00             	lea    0x0(%esi),%esi
  801dd0:	29 f9                	sub    %edi,%ecx
  801dd2:	19 d6                	sbb    %edx,%esi
  801dd4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dd8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ddc:	e9 18 ff ff ff       	jmp    801cf9 <__umoddi3+0x69>
