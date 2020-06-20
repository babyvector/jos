
obj/user/badsegment.debug:     file format elf32-i386


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
  80002c:	e8 0d 00 00 00       	call   80003e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	// Try to load the kernel's TSS selector into the DS register.
	asm volatile("movw $0x28,%ax; movw %ax,%ds");
  800036:	66 b8 28 00          	mov    $0x28,%ax
  80003a:	8e d8                	mov    %eax,%ds
}
  80003c:	5d                   	pop    %ebp
  80003d:	c3                   	ret    

0080003e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80003e:	55                   	push   %ebp
  80003f:	89 e5                	mov    %esp,%ebp
  800041:	56                   	push   %esi
  800042:	53                   	push   %ebx
  800043:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800046:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800049:	e8 ce 00 00 00       	call   80011c <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006b:	83 ec 08             	sub    $0x8,%esp
  80006e:	56                   	push   %esi
  80006f:	53                   	push   %ebx
  800070:	e8 be ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800075:	e8 0a 00 00 00       	call   800084 <exit>
}
  80007a:	83 c4 10             	add    $0x10,%esp
  80007d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800080:	5b                   	pop    %ebx
  800081:	5e                   	pop    %esi
  800082:	5d                   	pop    %ebp
  800083:	c3                   	ret    

00800084 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800084:	55                   	push   %ebp
  800085:	89 e5                	mov    %esp,%ebp
  800087:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008a:	e8 87 04 00 00       	call   800516 <close_all>
	sys_env_destroy(0);
  80008f:	83 ec 0c             	sub    $0xc,%esp
  800092:	6a 00                	push   $0x0
  800094:	e8 42 00 00 00       	call   8000db <sys_env_destroy>
}
  800099:	83 c4 10             	add    $0x10,%esp
  80009c:	c9                   	leave  
  80009d:	c3                   	ret    

0080009e <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  80009e:	55                   	push   %ebp
  80009f:	89 e5                	mov    %esp,%ebp
  8000a1:	57                   	push   %edi
  8000a2:	56                   	push   %esi
  8000a3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000a4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000ac:	8b 55 08             	mov    0x8(%ebp),%edx
  8000af:	89 c3                	mov    %eax,%ebx
  8000b1:	89 c7                	mov    %eax,%edi
  8000b3:	89 c6                	mov    %eax,%esi
  8000b5:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000b7:	5b                   	pop    %ebx
  8000b8:	5e                   	pop    %esi
  8000b9:	5f                   	pop    %edi
  8000ba:	5d                   	pop    %ebp
  8000bb:	c3                   	ret    

008000bc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000bc:	55                   	push   %ebp
  8000bd:	89 e5                	mov    %esp,%ebp
  8000bf:	57                   	push   %edi
  8000c0:	56                   	push   %esi
  8000c1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000c7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000cc:	89 d1                	mov    %edx,%ecx
  8000ce:	89 d3                	mov    %edx,%ebx
  8000d0:	89 d7                	mov    %edx,%edi
  8000d2:	89 d6                	mov    %edx,%esi
  8000d4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000d6:	5b                   	pop    %ebx
  8000d7:	5e                   	pop    %esi
  8000d8:	5f                   	pop    %edi
  8000d9:	5d                   	pop    %ebp
  8000da:	c3                   	ret    

008000db <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000db:	55                   	push   %ebp
  8000dc:	89 e5                	mov    %esp,%ebp
  8000de:	57                   	push   %edi
  8000df:	56                   	push   %esi
  8000e0:	53                   	push   %ebx
  8000e1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000e4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000ee:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f1:	89 cb                	mov    %ecx,%ebx
  8000f3:	89 cf                	mov    %ecx,%edi
  8000f5:	89 ce                	mov    %ecx,%esi
  8000f7:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8000f9:	85 c0                	test   %eax,%eax
  8000fb:	7e 17                	jle    800114 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000fd:	83 ec 0c             	sub    $0xc,%esp
  800100:	50                   	push   %eax
  800101:	6a 03                	push   $0x3
  800103:	68 ea 1d 80 00       	push   $0x801dea
  800108:	6a 23                	push   $0x23
  80010a:	68 07 1e 80 00       	push   $0x801e07
  80010f:	e8 1a 0f 00 00       	call   80102e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800114:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800117:	5b                   	pop    %ebx
  800118:	5e                   	pop    %esi
  800119:	5f                   	pop    %edi
  80011a:	5d                   	pop    %ebp
  80011b:	c3                   	ret    

0080011c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80011c:	55                   	push   %ebp
  80011d:	89 e5                	mov    %esp,%ebp
  80011f:	57                   	push   %edi
  800120:	56                   	push   %esi
  800121:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800122:	ba 00 00 00 00       	mov    $0x0,%edx
  800127:	b8 02 00 00 00       	mov    $0x2,%eax
  80012c:	89 d1                	mov    %edx,%ecx
  80012e:	89 d3                	mov    %edx,%ebx
  800130:	89 d7                	mov    %edx,%edi
  800132:	89 d6                	mov    %edx,%esi
  800134:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800136:	5b                   	pop    %ebx
  800137:	5e                   	pop    %esi
  800138:	5f                   	pop    %edi
  800139:	5d                   	pop    %ebp
  80013a:	c3                   	ret    

0080013b <sys_yield>:

void
sys_yield(void)
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
  800146:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014b:	89 d1                	mov    %edx,%ecx
  80014d:	89 d3                	mov    %edx,%ebx
  80014f:	89 d7                	mov    %edx,%edi
  800151:	89 d6                	mov    %edx,%esi
  800153:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800155:	5b                   	pop    %ebx
  800156:	5e                   	pop    %esi
  800157:	5f                   	pop    %edi
  800158:	5d                   	pop    %ebp
  800159:	c3                   	ret    

0080015a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015a:	55                   	push   %ebp
  80015b:	89 e5                	mov    %esp,%ebp
  80015d:	57                   	push   %edi
  80015e:	56                   	push   %esi
  80015f:	53                   	push   %ebx
  800160:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800163:	be 00 00 00 00       	mov    $0x0,%esi
  800168:	b8 04 00 00 00       	mov    $0x4,%eax
  80016d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800170:	8b 55 08             	mov    0x8(%ebp),%edx
  800173:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800176:	89 f7                	mov    %esi,%edi
  800178:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80017a:	85 c0                	test   %eax,%eax
  80017c:	7e 17                	jle    800195 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80017e:	83 ec 0c             	sub    $0xc,%esp
  800181:	50                   	push   %eax
  800182:	6a 04                	push   $0x4
  800184:	68 ea 1d 80 00       	push   $0x801dea
  800189:	6a 23                	push   $0x23
  80018b:	68 07 1e 80 00       	push   $0x801e07
  800190:	e8 99 0e 00 00       	call   80102e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800195:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800198:	5b                   	pop    %ebx
  800199:	5e                   	pop    %esi
  80019a:	5f                   	pop    %edi
  80019b:	5d                   	pop    %ebp
  80019c:	c3                   	ret    

0080019d <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  80019d:	55                   	push   %ebp
  80019e:	89 e5                	mov    %esp,%ebp
  8001a0:	57                   	push   %edi
  8001a1:	56                   	push   %esi
  8001a2:	53                   	push   %ebx
  8001a3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001a6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001ab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ae:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001b7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ba:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8001bc:	85 c0                	test   %eax,%eax
  8001be:	7e 17                	jle    8001d7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c0:	83 ec 0c             	sub    $0xc,%esp
  8001c3:	50                   	push   %eax
  8001c4:	6a 05                	push   $0x5
  8001c6:	68 ea 1d 80 00       	push   $0x801dea
  8001cb:	6a 23                	push   $0x23
  8001cd:	68 07 1e 80 00       	push   $0x801e07
  8001d2:	e8 57 0e 00 00       	call   80102e <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001da:	5b                   	pop    %ebx
  8001db:	5e                   	pop    %esi
  8001dc:	5f                   	pop    %edi
  8001dd:	5d                   	pop    %ebp
  8001de:	c3                   	ret    

008001df <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001df:	55                   	push   %ebp
  8001e0:	89 e5                	mov    %esp,%ebp
  8001e2:	57                   	push   %edi
  8001e3:	56                   	push   %esi
  8001e4:	53                   	push   %ebx
  8001e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001e8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001ed:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f5:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f8:	89 df                	mov    %ebx,%edi
  8001fa:	89 de                	mov    %ebx,%esi
  8001fc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8001fe:	85 c0                	test   %eax,%eax
  800200:	7e 17                	jle    800219 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800202:	83 ec 0c             	sub    $0xc,%esp
  800205:	50                   	push   %eax
  800206:	6a 06                	push   $0x6
  800208:	68 ea 1d 80 00       	push   $0x801dea
  80020d:	6a 23                	push   $0x23
  80020f:	68 07 1e 80 00       	push   $0x801e07
  800214:	e8 15 0e 00 00       	call   80102e <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800219:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80021c:	5b                   	pop    %ebx
  80021d:	5e                   	pop    %esi
  80021e:	5f                   	pop    %edi
  80021f:	5d                   	pop    %ebp
  800220:	c3                   	ret    

00800221 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800221:	55                   	push   %ebp
  800222:	89 e5                	mov    %esp,%ebp
  800224:	57                   	push   %edi
  800225:	56                   	push   %esi
  800226:	53                   	push   %ebx
  800227:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80022a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80022f:	b8 08 00 00 00       	mov    $0x8,%eax
  800234:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800237:	8b 55 08             	mov    0x8(%ebp),%edx
  80023a:	89 df                	mov    %ebx,%edi
  80023c:	89 de                	mov    %ebx,%esi
  80023e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800240:	85 c0                	test   %eax,%eax
  800242:	7e 17                	jle    80025b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800244:	83 ec 0c             	sub    $0xc,%esp
  800247:	50                   	push   %eax
  800248:	6a 08                	push   $0x8
  80024a:	68 ea 1d 80 00       	push   $0x801dea
  80024f:	6a 23                	push   $0x23
  800251:	68 07 1e 80 00       	push   $0x801e07
  800256:	e8 d3 0d 00 00       	call   80102e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80025e:	5b                   	pop    %ebx
  80025f:	5e                   	pop    %esi
  800260:	5f                   	pop    %edi
  800261:	5d                   	pop    %ebp
  800262:	c3                   	ret    

00800263 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800263:	55                   	push   %ebp
  800264:	89 e5                	mov    %esp,%ebp
  800266:	57                   	push   %edi
  800267:	56                   	push   %esi
  800268:	53                   	push   %ebx
  800269:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80026c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800271:	b8 09 00 00 00       	mov    $0x9,%eax
  800276:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800279:	8b 55 08             	mov    0x8(%ebp),%edx
  80027c:	89 df                	mov    %ebx,%edi
  80027e:	89 de                	mov    %ebx,%esi
  800280:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800282:	85 c0                	test   %eax,%eax
  800284:	7e 17                	jle    80029d <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800286:	83 ec 0c             	sub    $0xc,%esp
  800289:	50                   	push   %eax
  80028a:	6a 09                	push   $0x9
  80028c:	68 ea 1d 80 00       	push   $0x801dea
  800291:	6a 23                	push   $0x23
  800293:	68 07 1e 80 00       	push   $0x801e07
  800298:	e8 91 0d 00 00       	call   80102e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  80029d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a0:	5b                   	pop    %ebx
  8002a1:	5e                   	pop    %esi
  8002a2:	5f                   	pop    %edi
  8002a3:	5d                   	pop    %ebp
  8002a4:	c3                   	ret    

008002a5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a5:	55                   	push   %ebp
  8002a6:	89 e5                	mov    %esp,%ebp
  8002a8:	57                   	push   %edi
  8002a9:	56                   	push   %esi
  8002aa:	53                   	push   %ebx
  8002ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002ae:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002b8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002be:	89 df                	mov    %ebx,%edi
  8002c0:	89 de                	mov    %ebx,%esi
  8002c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8002c4:	85 c0                	test   %eax,%eax
  8002c6:	7e 17                	jle    8002df <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002c8:	83 ec 0c             	sub    $0xc,%esp
  8002cb:	50                   	push   %eax
  8002cc:	6a 0a                	push   $0xa
  8002ce:	68 ea 1d 80 00       	push   $0x801dea
  8002d3:	6a 23                	push   $0x23
  8002d5:	68 07 1e 80 00       	push   $0x801e07
  8002da:	e8 4f 0d 00 00       	call   80102e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e2:	5b                   	pop    %ebx
  8002e3:	5e                   	pop    %esi
  8002e4:	5f                   	pop    %edi
  8002e5:	5d                   	pop    %ebp
  8002e6:	c3                   	ret    

008002e7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002e7:	55                   	push   %ebp
  8002e8:	89 e5                	mov    %esp,%ebp
  8002ea:	57                   	push   %edi
  8002eb:	56                   	push   %esi
  8002ec:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002ed:	be 00 00 00 00       	mov    $0x0,%esi
  8002f2:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002f7:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fa:	8b 55 08             	mov    0x8(%ebp),%edx
  8002fd:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800300:	8b 7d 14             	mov    0x14(%ebp),%edi
  800303:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800305:	5b                   	pop    %ebx
  800306:	5e                   	pop    %esi
  800307:	5f                   	pop    %edi
  800308:	5d                   	pop    %ebp
  800309:	c3                   	ret    

0080030a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030a:	55                   	push   %ebp
  80030b:	89 e5                	mov    %esp,%ebp
  80030d:	57                   	push   %edi
  80030e:	56                   	push   %esi
  80030f:	53                   	push   %ebx
  800310:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800313:	b9 00 00 00 00       	mov    $0x0,%ecx
  800318:	b8 0d 00 00 00       	mov    $0xd,%eax
  80031d:	8b 55 08             	mov    0x8(%ebp),%edx
  800320:	89 cb                	mov    %ecx,%ebx
  800322:	89 cf                	mov    %ecx,%edi
  800324:	89 ce                	mov    %ecx,%esi
  800326:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800328:	85 c0                	test   %eax,%eax
  80032a:	7e 17                	jle    800343 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80032c:	83 ec 0c             	sub    $0xc,%esp
  80032f:	50                   	push   %eax
  800330:	6a 0d                	push   $0xd
  800332:	68 ea 1d 80 00       	push   $0x801dea
  800337:	6a 23                	push   $0x23
  800339:	68 07 1e 80 00       	push   $0x801e07
  80033e:	e8 eb 0c 00 00       	call   80102e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800343:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800346:	5b                   	pop    %ebx
  800347:	5e                   	pop    %esi
  800348:	5f                   	pop    %edi
  800349:	5d                   	pop    %ebp
  80034a:	c3                   	ret    

0080034b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034b:	55                   	push   %ebp
  80034c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80034e:	8b 45 08             	mov    0x8(%ebp),%eax
  800351:	05 00 00 00 30       	add    $0x30000000,%eax
  800356:	c1 e8 0c             	shr    $0xc,%eax
}
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800370:	5d                   	pop    %ebp
  800371:	c3                   	ret    

00800372 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800372:	55                   	push   %ebp
  800373:	89 e5                	mov    %esp,%ebp
  800375:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800378:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80037d:	89 c2                	mov    %eax,%edx
  80037f:	c1 ea 16             	shr    $0x16,%edx
  800382:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800389:	f6 c2 01             	test   $0x1,%dl
  80038c:	74 11                	je     80039f <fd_alloc+0x2d>
  80038e:	89 c2                	mov    %eax,%edx
  800390:	c1 ea 0c             	shr    $0xc,%edx
  800393:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039a:	f6 c2 01             	test   $0x1,%dl
  80039d:	75 09                	jne    8003a8 <fd_alloc+0x36>
			*fd_store = fd;
  80039f:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003a6:	eb 17                	jmp    8003bf <fd_alloc+0x4d>
  8003a8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003ad:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b2:	75 c9                	jne    80037d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ba:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003bf:	5d                   	pop    %ebp
  8003c0:	c3                   	ret    

008003c1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c1:	55                   	push   %ebp
  8003c2:	89 e5                	mov    %esp,%ebp
  8003c4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003c7:	83 f8 1f             	cmp    $0x1f,%eax
  8003ca:	77 36                	ja     800402 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003cc:	c1 e0 0c             	shl    $0xc,%eax
  8003cf:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d4:	89 c2                	mov    %eax,%edx
  8003d6:	c1 ea 16             	shr    $0x16,%edx
  8003d9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e0:	f6 c2 01             	test   $0x1,%dl
  8003e3:	74 24                	je     800409 <fd_lookup+0x48>
  8003e5:	89 c2                	mov    %eax,%edx
  8003e7:	c1 ea 0c             	shr    $0xc,%edx
  8003ea:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f1:	f6 c2 01             	test   $0x1,%dl
  8003f4:	74 1a                	je     800410 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003f6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003f9:	89 02                	mov    %eax,(%edx)
	return 0;
  8003fb:	b8 00 00 00 00       	mov    $0x0,%eax
  800400:	eb 13                	jmp    800415 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800402:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800407:	eb 0c                	jmp    800415 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800409:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040e:	eb 05                	jmp    800415 <fd_lookup+0x54>
  800410:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800415:	5d                   	pop    %ebp
  800416:	c3                   	ret    

00800417 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800417:	55                   	push   %ebp
  800418:	89 e5                	mov    %esp,%ebp
  80041a:	83 ec 08             	sub    $0x8,%esp
  80041d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800420:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800425:	eb 13                	jmp    80043a <dev_lookup+0x23>
  800427:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042a:	39 08                	cmp    %ecx,(%eax)
  80042c:	75 0c                	jne    80043a <dev_lookup+0x23>
			*dev = devtab[i];
  80042e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800431:	89 01                	mov    %eax,(%ecx)
			return 0;
  800433:	b8 00 00 00 00       	mov    $0x0,%eax
  800438:	eb 2e                	jmp    800468 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043a:	8b 02                	mov    (%edx),%eax
  80043c:	85 c0                	test   %eax,%eax
  80043e:	75 e7                	jne    800427 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800440:	a1 04 40 80 00       	mov    0x804004,%eax
  800445:	8b 40 48             	mov    0x48(%eax),%eax
  800448:	83 ec 04             	sub    $0x4,%esp
  80044b:	51                   	push   %ecx
  80044c:	50                   	push   %eax
  80044d:	68 18 1e 80 00       	push   $0x801e18
  800452:	e8 b0 0c 00 00       	call   801107 <cprintf>
	*dev = 0;
  800457:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800460:	83 c4 10             	add    $0x10,%esp
  800463:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800468:	c9                   	leave  
  800469:	c3                   	ret    

0080046a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046a:	55                   	push   %ebp
  80046b:	89 e5                	mov    %esp,%ebp
  80046d:	56                   	push   %esi
  80046e:	53                   	push   %ebx
  80046f:	83 ec 10             	sub    $0x10,%esp
  800472:	8b 75 08             	mov    0x8(%ebp),%esi
  800475:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800478:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047b:	50                   	push   %eax
  80047c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800482:	c1 e8 0c             	shr    $0xc,%eax
  800485:	50                   	push   %eax
  800486:	e8 36 ff ff ff       	call   8003c1 <fd_lookup>
  80048b:	83 c4 08             	add    $0x8,%esp
  80048e:	85 c0                	test   %eax,%eax
  800490:	78 05                	js     800497 <fd_close+0x2d>
	    || fd != fd2)
  800492:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800495:	74 0c                	je     8004a3 <fd_close+0x39>
		return (must_exist ? r : 0);
  800497:	84 db                	test   %bl,%bl
  800499:	ba 00 00 00 00       	mov    $0x0,%edx
  80049e:	0f 44 c2             	cmove  %edx,%eax
  8004a1:	eb 41                	jmp    8004e4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a3:	83 ec 08             	sub    $0x8,%esp
  8004a6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004a9:	50                   	push   %eax
  8004aa:	ff 36                	pushl  (%esi)
  8004ac:	e8 66 ff ff ff       	call   800417 <dev_lookup>
  8004b1:	89 c3                	mov    %eax,%ebx
  8004b3:	83 c4 10             	add    $0x10,%esp
  8004b6:	85 c0                	test   %eax,%eax
  8004b8:	78 1a                	js     8004d4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ba:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004bd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c5:	85 c0                	test   %eax,%eax
  8004c7:	74 0b                	je     8004d4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004c9:	83 ec 0c             	sub    $0xc,%esp
  8004cc:	56                   	push   %esi
  8004cd:	ff d0                	call   *%eax
  8004cf:	89 c3                	mov    %eax,%ebx
  8004d1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d4:	83 ec 08             	sub    $0x8,%esp
  8004d7:	56                   	push   %esi
  8004d8:	6a 00                	push   $0x0
  8004da:	e8 00 fd ff ff       	call   8001df <sys_page_unmap>
	return r;
  8004df:	83 c4 10             	add    $0x10,%esp
  8004e2:	89 d8                	mov    %ebx,%eax
}
  8004e4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004e7:	5b                   	pop    %ebx
  8004e8:	5e                   	pop    %esi
  8004e9:	5d                   	pop    %ebp
  8004ea:	c3                   	ret    

008004eb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004eb:	55                   	push   %ebp
  8004ec:	89 e5                	mov    %esp,%ebp
  8004ee:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f4:	50                   	push   %eax
  8004f5:	ff 75 08             	pushl  0x8(%ebp)
  8004f8:	e8 c4 fe ff ff       	call   8003c1 <fd_lookup>
  8004fd:	83 c4 08             	add    $0x8,%esp
  800500:	85 c0                	test   %eax,%eax
  800502:	78 10                	js     800514 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800504:	83 ec 08             	sub    $0x8,%esp
  800507:	6a 01                	push   $0x1
  800509:	ff 75 f4             	pushl  -0xc(%ebp)
  80050c:	e8 59 ff ff ff       	call   80046a <fd_close>
  800511:	83 c4 10             	add    $0x10,%esp
}
  800514:	c9                   	leave  
  800515:	c3                   	ret    

00800516 <close_all>:

void
close_all(void)
{
  800516:	55                   	push   %ebp
  800517:	89 e5                	mov    %esp,%ebp
  800519:	53                   	push   %ebx
  80051a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80051d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800522:	83 ec 0c             	sub    $0xc,%esp
  800525:	53                   	push   %ebx
  800526:	e8 c0 ff ff ff       	call   8004eb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052b:	83 c3 01             	add    $0x1,%ebx
  80052e:	83 c4 10             	add    $0x10,%esp
  800531:	83 fb 20             	cmp    $0x20,%ebx
  800534:	75 ec                	jne    800522 <close_all+0xc>
		close(i);
}
  800536:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800539:	c9                   	leave  
  80053a:	c3                   	ret    

0080053b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053b:	55                   	push   %ebp
  80053c:	89 e5                	mov    %esp,%ebp
  80053e:	57                   	push   %edi
  80053f:	56                   	push   %esi
  800540:	53                   	push   %ebx
  800541:	83 ec 2c             	sub    $0x2c,%esp
  800544:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800547:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054a:	50                   	push   %eax
  80054b:	ff 75 08             	pushl  0x8(%ebp)
  80054e:	e8 6e fe ff ff       	call   8003c1 <fd_lookup>
  800553:	83 c4 08             	add    $0x8,%esp
  800556:	85 c0                	test   %eax,%eax
  800558:	0f 88 c1 00 00 00    	js     80061f <dup+0xe4>
		return r;
	close(newfdnum);
  80055e:	83 ec 0c             	sub    $0xc,%esp
  800561:	56                   	push   %esi
  800562:	e8 84 ff ff ff       	call   8004eb <close>

	newfd = INDEX2FD(newfdnum);
  800567:	89 f3                	mov    %esi,%ebx
  800569:	c1 e3 0c             	shl    $0xc,%ebx
  80056c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800572:	83 c4 04             	add    $0x4,%esp
  800575:	ff 75 e4             	pushl  -0x1c(%ebp)
  800578:	e8 de fd ff ff       	call   80035b <fd2data>
  80057d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80057f:	89 1c 24             	mov    %ebx,(%esp)
  800582:	e8 d4 fd ff ff       	call   80035b <fd2data>
  800587:	83 c4 10             	add    $0x10,%esp
  80058a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80058d:	89 f8                	mov    %edi,%eax
  80058f:	c1 e8 16             	shr    $0x16,%eax
  800592:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  800599:	a8 01                	test   $0x1,%al
  80059b:	74 37                	je     8005d4 <dup+0x99>
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 0c             	shr    $0xc,%eax
  8005a2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005a9:	f6 c2 01             	test   $0x1,%dl
  8005ac:	74 26                	je     8005d4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005ae:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b5:	83 ec 0c             	sub    $0xc,%esp
  8005b8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005bd:	50                   	push   %eax
  8005be:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c1:	6a 00                	push   $0x0
  8005c3:	57                   	push   %edi
  8005c4:	6a 00                	push   $0x0
  8005c6:	e8 d2 fb ff ff       	call   80019d <sys_page_map>
  8005cb:	89 c7                	mov    %eax,%edi
  8005cd:	83 c4 20             	add    $0x20,%esp
  8005d0:	85 c0                	test   %eax,%eax
  8005d2:	78 2e                	js     800602 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005d7:	89 d0                	mov    %edx,%eax
  8005d9:	c1 e8 0c             	shr    $0xc,%eax
  8005dc:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e3:	83 ec 0c             	sub    $0xc,%esp
  8005e6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005eb:	50                   	push   %eax
  8005ec:	53                   	push   %ebx
  8005ed:	6a 00                	push   $0x0
  8005ef:	52                   	push   %edx
  8005f0:	6a 00                	push   $0x0
  8005f2:	e8 a6 fb ff ff       	call   80019d <sys_page_map>
  8005f7:	89 c7                	mov    %eax,%edi
  8005f9:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  8005fc:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005fe:	85 ff                	test   %edi,%edi
  800600:	79 1d                	jns    80061f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800602:	83 ec 08             	sub    $0x8,%esp
  800605:	53                   	push   %ebx
  800606:	6a 00                	push   $0x0
  800608:	e8 d2 fb ff ff       	call   8001df <sys_page_unmap>
	sys_page_unmap(0, nva);
  80060d:	83 c4 08             	add    $0x8,%esp
  800610:	ff 75 d4             	pushl  -0x2c(%ebp)
  800613:	6a 00                	push   $0x0
  800615:	e8 c5 fb ff ff       	call   8001df <sys_page_unmap>
	return r;
  80061a:	83 c4 10             	add    $0x10,%esp
  80061d:	89 f8                	mov    %edi,%eax
}
  80061f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800622:	5b                   	pop    %ebx
  800623:	5e                   	pop    %esi
  800624:	5f                   	pop    %edi
  800625:	5d                   	pop    %ebp
  800626:	c3                   	ret    

00800627 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800627:	55                   	push   %ebp
  800628:	89 e5                	mov    %esp,%ebp
  80062a:	53                   	push   %ebx
  80062b:	83 ec 14             	sub    $0x14,%esp
  80062e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800631:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800634:	50                   	push   %eax
  800635:	53                   	push   %ebx
  800636:	e8 86 fd ff ff       	call   8003c1 <fd_lookup>
  80063b:	83 c4 08             	add    $0x8,%esp
  80063e:	89 c2                	mov    %eax,%edx
  800640:	85 c0                	test   %eax,%eax
  800642:	78 6d                	js     8006b1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800644:	83 ec 08             	sub    $0x8,%esp
  800647:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064a:	50                   	push   %eax
  80064b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80064e:	ff 30                	pushl  (%eax)
  800650:	e8 c2 fd ff ff       	call   800417 <dev_lookup>
  800655:	83 c4 10             	add    $0x10,%esp
  800658:	85 c0                	test   %eax,%eax
  80065a:	78 4c                	js     8006a8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80065c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80065f:	8b 42 08             	mov    0x8(%edx),%eax
  800662:	83 e0 03             	and    $0x3,%eax
  800665:	83 f8 01             	cmp    $0x1,%eax
  800668:	75 21                	jne    80068b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066a:	a1 04 40 80 00       	mov    0x804004,%eax
  80066f:	8b 40 48             	mov    0x48(%eax),%eax
  800672:	83 ec 04             	sub    $0x4,%esp
  800675:	53                   	push   %ebx
  800676:	50                   	push   %eax
  800677:	68 59 1e 80 00       	push   $0x801e59
  80067c:	e8 86 0a 00 00       	call   801107 <cprintf>
		return -E_INVAL;
  800681:	83 c4 10             	add    $0x10,%esp
  800684:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800689:	eb 26                	jmp    8006b1 <read+0x8a>
	}
	if (!dev->dev_read)
  80068b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80068e:	8b 40 08             	mov    0x8(%eax),%eax
  800691:	85 c0                	test   %eax,%eax
  800693:	74 17                	je     8006ac <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800695:	83 ec 04             	sub    $0x4,%esp
  800698:	ff 75 10             	pushl  0x10(%ebp)
  80069b:	ff 75 0c             	pushl  0xc(%ebp)
  80069e:	52                   	push   %edx
  80069f:	ff d0                	call   *%eax
  8006a1:	89 c2                	mov    %eax,%edx
  8006a3:	83 c4 10             	add    $0x10,%esp
  8006a6:	eb 09                	jmp    8006b1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006a8:	89 c2                	mov    %eax,%edx
  8006aa:	eb 05                	jmp    8006b1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006ac:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b1:	89 d0                	mov    %edx,%eax
  8006b3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006b6:	c9                   	leave  
  8006b7:	c3                   	ret    

008006b8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006b8:	55                   	push   %ebp
  8006b9:	89 e5                	mov    %esp,%ebp
  8006bb:	57                   	push   %edi
  8006bc:	56                   	push   %esi
  8006bd:	53                   	push   %ebx
  8006be:	83 ec 0c             	sub    $0xc,%esp
  8006c1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006c7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006cc:	eb 21                	jmp    8006ef <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006ce:	83 ec 04             	sub    $0x4,%esp
  8006d1:	89 f0                	mov    %esi,%eax
  8006d3:	29 d8                	sub    %ebx,%eax
  8006d5:	50                   	push   %eax
  8006d6:	89 d8                	mov    %ebx,%eax
  8006d8:	03 45 0c             	add    0xc(%ebp),%eax
  8006db:	50                   	push   %eax
  8006dc:	57                   	push   %edi
  8006dd:	e8 45 ff ff ff       	call   800627 <read>
		if (m < 0)
  8006e2:	83 c4 10             	add    $0x10,%esp
  8006e5:	85 c0                	test   %eax,%eax
  8006e7:	78 10                	js     8006f9 <readn+0x41>
			return m;
		if (m == 0)
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	74 0a                	je     8006f7 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006ed:	01 c3                	add    %eax,%ebx
  8006ef:	39 f3                	cmp    %esi,%ebx
  8006f1:	72 db                	jb     8006ce <readn+0x16>
  8006f3:	89 d8                	mov    %ebx,%eax
  8006f5:	eb 02                	jmp    8006f9 <readn+0x41>
  8006f7:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8006fc:	5b                   	pop    %ebx
  8006fd:	5e                   	pop    %esi
  8006fe:	5f                   	pop    %edi
  8006ff:	5d                   	pop    %ebp
  800700:	c3                   	ret    

00800701 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800701:	55                   	push   %ebp
  800702:	89 e5                	mov    %esp,%ebp
  800704:	53                   	push   %ebx
  800705:	83 ec 14             	sub    $0x14,%esp
  800708:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80070e:	50                   	push   %eax
  80070f:	53                   	push   %ebx
  800710:	e8 ac fc ff ff       	call   8003c1 <fd_lookup>
  800715:	83 c4 08             	add    $0x8,%esp
  800718:	89 c2                	mov    %eax,%edx
  80071a:	85 c0                	test   %eax,%eax
  80071c:	78 68                	js     800786 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80071e:	83 ec 08             	sub    $0x8,%esp
  800721:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800724:	50                   	push   %eax
  800725:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800728:	ff 30                	pushl  (%eax)
  80072a:	e8 e8 fc ff ff       	call   800417 <dev_lookup>
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	85 c0                	test   %eax,%eax
  800734:	78 47                	js     80077d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800736:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800739:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80073d:	75 21                	jne    800760 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80073f:	a1 04 40 80 00       	mov    0x804004,%eax
  800744:	8b 40 48             	mov    0x48(%eax),%eax
  800747:	83 ec 04             	sub    $0x4,%esp
  80074a:	53                   	push   %ebx
  80074b:	50                   	push   %eax
  80074c:	68 75 1e 80 00       	push   $0x801e75
  800751:	e8 b1 09 00 00       	call   801107 <cprintf>
		return -E_INVAL;
  800756:	83 c4 10             	add    $0x10,%esp
  800759:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80075e:	eb 26                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800760:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800763:	8b 52 0c             	mov    0xc(%edx),%edx
  800766:	85 d2                	test   %edx,%edx
  800768:	74 17                	je     800781 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076a:	83 ec 04             	sub    $0x4,%esp
  80076d:	ff 75 10             	pushl  0x10(%ebp)
  800770:	ff 75 0c             	pushl  0xc(%ebp)
  800773:	50                   	push   %eax
  800774:	ff d2                	call   *%edx
  800776:	89 c2                	mov    %eax,%edx
  800778:	83 c4 10             	add    $0x10,%esp
  80077b:	eb 09                	jmp    800786 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80077d:	89 c2                	mov    %eax,%edx
  80077f:	eb 05                	jmp    800786 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800781:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800786:	89 d0                	mov    %edx,%eax
  800788:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078b:	c9                   	leave  
  80078c:	c3                   	ret    

0080078d <seek>:

int
seek(int fdnum, off_t offset)
{
  80078d:	55                   	push   %ebp
  80078e:	89 e5                	mov    %esp,%ebp
  800790:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800793:	8d 45 fc             	lea    -0x4(%ebp),%eax
  800796:	50                   	push   %eax
  800797:	ff 75 08             	pushl  0x8(%ebp)
  80079a:	e8 22 fc ff ff       	call   8003c1 <fd_lookup>
  80079f:	83 c4 08             	add    $0x8,%esp
  8007a2:	85 c0                	test   %eax,%eax
  8007a4:	78 0e                	js     8007b4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007a6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007a9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007ac:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007af:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b4:	c9                   	leave  
  8007b5:	c3                   	ret    

008007b6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007b6:	55                   	push   %ebp
  8007b7:	89 e5                	mov    %esp,%ebp
  8007b9:	53                   	push   %ebx
  8007ba:	83 ec 14             	sub    $0x14,%esp
  8007bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c3:	50                   	push   %eax
  8007c4:	53                   	push   %ebx
  8007c5:	e8 f7 fb ff ff       	call   8003c1 <fd_lookup>
  8007ca:	83 c4 08             	add    $0x8,%esp
  8007cd:	89 c2                	mov    %eax,%edx
  8007cf:	85 c0                	test   %eax,%eax
  8007d1:	78 65                	js     800838 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d3:	83 ec 08             	sub    $0x8,%esp
  8007d6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007d9:	50                   	push   %eax
  8007da:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007dd:	ff 30                	pushl  (%eax)
  8007df:	e8 33 fc ff ff       	call   800417 <dev_lookup>
  8007e4:	83 c4 10             	add    $0x10,%esp
  8007e7:	85 c0                	test   %eax,%eax
  8007e9:	78 44                	js     80082f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007eb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ee:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f2:	75 21                	jne    800815 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f4:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007f9:	8b 40 48             	mov    0x48(%eax),%eax
  8007fc:	83 ec 04             	sub    $0x4,%esp
  8007ff:	53                   	push   %ebx
  800800:	50                   	push   %eax
  800801:	68 38 1e 80 00       	push   $0x801e38
  800806:	e8 fc 08 00 00       	call   801107 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080b:	83 c4 10             	add    $0x10,%esp
  80080e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800813:	eb 23                	jmp    800838 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800815:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800818:	8b 52 18             	mov    0x18(%edx),%edx
  80081b:	85 d2                	test   %edx,%edx
  80081d:	74 14                	je     800833 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80081f:	83 ec 08             	sub    $0x8,%esp
  800822:	ff 75 0c             	pushl  0xc(%ebp)
  800825:	50                   	push   %eax
  800826:	ff d2                	call   *%edx
  800828:	89 c2                	mov    %eax,%edx
  80082a:	83 c4 10             	add    $0x10,%esp
  80082d:	eb 09                	jmp    800838 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80082f:	89 c2                	mov    %eax,%edx
  800831:	eb 05                	jmp    800838 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800833:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800838:	89 d0                	mov    %edx,%eax
  80083a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80083d:	c9                   	leave  
  80083e:	c3                   	ret    

0080083f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80083f:	55                   	push   %ebp
  800840:	89 e5                	mov    %esp,%ebp
  800842:	53                   	push   %ebx
  800843:	83 ec 14             	sub    $0x14,%esp
  800846:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800849:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80084c:	50                   	push   %eax
  80084d:	ff 75 08             	pushl  0x8(%ebp)
  800850:	e8 6c fb ff ff       	call   8003c1 <fd_lookup>
  800855:	83 c4 08             	add    $0x8,%esp
  800858:	89 c2                	mov    %eax,%edx
  80085a:	85 c0                	test   %eax,%eax
  80085c:	78 58                	js     8008b6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80085e:	83 ec 08             	sub    $0x8,%esp
  800861:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800864:	50                   	push   %eax
  800865:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800868:	ff 30                	pushl  (%eax)
  80086a:	e8 a8 fb ff ff       	call   800417 <dev_lookup>
  80086f:	83 c4 10             	add    $0x10,%esp
  800872:	85 c0                	test   %eax,%eax
  800874:	78 37                	js     8008ad <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800876:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800879:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80087d:	74 32                	je     8008b1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80087f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800882:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800889:	00 00 00 
	stat->st_isdir = 0;
  80088c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800893:	00 00 00 
	stat->st_dev = dev;
  800896:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  80089c:	83 ec 08             	sub    $0x8,%esp
  80089f:	53                   	push   %ebx
  8008a0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a3:	ff 50 14             	call   *0x14(%eax)
  8008a6:	89 c2                	mov    %eax,%edx
  8008a8:	83 c4 10             	add    $0x10,%esp
  8008ab:	eb 09                	jmp    8008b6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008ad:	89 c2                	mov    %eax,%edx
  8008af:	eb 05                	jmp    8008b6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008b6:	89 d0                	mov    %edx,%eax
  8008b8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bb:	c9                   	leave  
  8008bc:	c3                   	ret    

008008bd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008bd:	55                   	push   %ebp
  8008be:	89 e5                	mov    %esp,%ebp
  8008c0:	56                   	push   %esi
  8008c1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c2:	83 ec 08             	sub    $0x8,%esp
  8008c5:	6a 00                	push   $0x0
  8008c7:	ff 75 08             	pushl  0x8(%ebp)
  8008ca:	e8 dc 01 00 00       	call   800aab <open>
  8008cf:	89 c3                	mov    %eax,%ebx
  8008d1:	83 c4 10             	add    $0x10,%esp
  8008d4:	85 c0                	test   %eax,%eax
  8008d6:	78 1b                	js     8008f3 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008d8:	83 ec 08             	sub    $0x8,%esp
  8008db:	ff 75 0c             	pushl  0xc(%ebp)
  8008de:	50                   	push   %eax
  8008df:	e8 5b ff ff ff       	call   80083f <fstat>
  8008e4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008e6:	89 1c 24             	mov    %ebx,(%esp)
  8008e9:	e8 fd fb ff ff       	call   8004eb <close>
	return r;
  8008ee:	83 c4 10             	add    $0x10,%esp
  8008f1:	89 f0                	mov    %esi,%eax
}
  8008f3:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008f6:	5b                   	pop    %ebx
  8008f7:	5e                   	pop    %esi
  8008f8:	5d                   	pop    %ebp
  8008f9:	c3                   	ret    

008008fa <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fa:	55                   	push   %ebp
  8008fb:	89 e5                	mov    %esp,%ebp
  8008fd:	56                   	push   %esi
  8008fe:	53                   	push   %ebx
  8008ff:	89 c6                	mov    %eax,%esi
  800901:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800903:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090a:	75 12                	jne    80091e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80090c:	83 ec 0c             	sub    $0xc,%esp
  80090f:	6a 01                	push   $0x1
  800911:	e8 a7 11 00 00       	call   801abd <ipc_find_env>
  800916:	a3 00 40 80 00       	mov    %eax,0x804000
  80091b:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80091e:	6a 07                	push   $0x7
  800920:	68 00 50 80 00       	push   $0x805000
  800925:	56                   	push   %esi
  800926:	ff 35 00 40 80 00    	pushl  0x804000
  80092c:	e8 49 11 00 00       	call   801a7a <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  800931:	83 c4 0c             	add    $0xc,%esp
  800934:	6a 00                	push   $0x0
  800936:	53                   	push   %ebx
  800937:	6a 00                	push   $0x0
  800939:	e8 df 10 00 00       	call   801a1d <ipc_recv>
}
  80093e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800941:	5b                   	pop    %ebx
  800942:	5e                   	pop    %esi
  800943:	5d                   	pop    %ebp
  800944:	c3                   	ret    

00800945 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800945:	55                   	push   %ebp
  800946:	89 e5                	mov    %esp,%ebp
  800948:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094b:	8b 45 08             	mov    0x8(%ebp),%eax
  80094e:	8b 40 0c             	mov    0xc(%eax),%eax
  800951:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800956:	8b 45 0c             	mov    0xc(%ebp),%eax
  800959:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80095e:	ba 00 00 00 00       	mov    $0x0,%edx
  800963:	b8 02 00 00 00       	mov    $0x2,%eax
  800968:	e8 8d ff ff ff       	call   8008fa <fsipc>
}
  80096d:	c9                   	leave  
  80096e:	c3                   	ret    

0080096f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80096f:	55                   	push   %ebp
  800970:	89 e5                	mov    %esp,%ebp
  800972:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800975:	8b 45 08             	mov    0x8(%ebp),%eax
  800978:	8b 40 0c             	mov    0xc(%eax),%eax
  80097b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800980:	ba 00 00 00 00       	mov    $0x0,%edx
  800985:	b8 06 00 00 00       	mov    $0x6,%eax
  80098a:	e8 6b ff ff ff       	call   8008fa <fsipc>
}
  80098f:	c9                   	leave  
  800990:	c3                   	ret    

00800991 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800991:	55                   	push   %ebp
  800992:	89 e5                	mov    %esp,%ebp
  800994:	53                   	push   %ebx
  800995:	83 ec 04             	sub    $0x4,%esp
  800998:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099b:	8b 45 08             	mov    0x8(%ebp),%eax
  80099e:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009a6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009ab:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b0:	e8 45 ff ff ff       	call   8008fa <fsipc>
  8009b5:	85 c0                	test   %eax,%eax
  8009b7:	78 2c                	js     8009e5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009b9:	83 ec 08             	sub    $0x8,%esp
  8009bc:	68 00 50 80 00       	push   $0x805000
  8009c1:	53                   	push   %ebx
  8009c2:	e8 0f 0d 00 00       	call   8016d6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009c7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009cc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009d7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009dd:	83 c4 10             	add    $0x10,%esp
  8009e0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e8:	c9                   	leave  
  8009e9:	c3                   	ret    

008009ea <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ea:	55                   	push   %ebp
  8009eb:	89 e5                	mov    %esp,%ebp
  8009ed:	83 ec 0c             	sub    $0xc,%esp
  8009f0:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f3:	8b 55 08             	mov    0x8(%ebp),%edx
  8009f6:	8b 52 0c             	mov    0xc(%edx),%edx
  8009f9:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  8009ff:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a04:	50                   	push   %eax
  800a05:	ff 75 0c             	pushl  0xc(%ebp)
  800a08:	68 08 50 80 00       	push   $0x805008
  800a0d:	e8 56 0e 00 00       	call   801868 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a12:	ba 00 00 00 00       	mov    $0x0,%edx
  800a17:	b8 04 00 00 00       	mov    $0x4,%eax
  800a1c:	e8 d9 fe ff ff       	call   8008fa <fsipc>
	//panic("devfile_write not implemented");
}
  800a21:	c9                   	leave  
  800a22:	c3                   	ret    

00800a23 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a23:	55                   	push   %ebp
  800a24:	89 e5                	mov    %esp,%ebp
  800a26:	56                   	push   %esi
  800a27:	53                   	push   %ebx
  800a28:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a2b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a2e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a31:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a36:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a41:	b8 03 00 00 00       	mov    $0x3,%eax
  800a46:	e8 af fe ff ff       	call   8008fa <fsipc>
  800a4b:	89 c3                	mov    %eax,%ebx
  800a4d:	85 c0                	test   %eax,%eax
  800a4f:	78 51                	js     800aa2 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a51:	39 c6                	cmp    %eax,%esi
  800a53:	73 19                	jae    800a6e <devfile_read+0x4b>
  800a55:	68 a4 1e 80 00       	push   $0x801ea4
  800a5a:	68 ab 1e 80 00       	push   $0x801eab
  800a5f:	68 80 00 00 00       	push   $0x80
  800a64:	68 c0 1e 80 00       	push   $0x801ec0
  800a69:	e8 c0 05 00 00       	call   80102e <_panic>
	assert(r <= PGSIZE);
  800a6e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a73:	7e 19                	jle    800a8e <devfile_read+0x6b>
  800a75:	68 cb 1e 80 00       	push   $0x801ecb
  800a7a:	68 ab 1e 80 00       	push   $0x801eab
  800a7f:	68 81 00 00 00       	push   $0x81
  800a84:	68 c0 1e 80 00       	push   $0x801ec0
  800a89:	e8 a0 05 00 00       	call   80102e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a8e:	83 ec 04             	sub    $0x4,%esp
  800a91:	50                   	push   %eax
  800a92:	68 00 50 80 00       	push   $0x805000
  800a97:	ff 75 0c             	pushl  0xc(%ebp)
  800a9a:	e8 c9 0d 00 00       	call   801868 <memmove>
	return r;
  800a9f:	83 c4 10             	add    $0x10,%esp
}
  800aa2:	89 d8                	mov    %ebx,%eax
  800aa4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aa7:	5b                   	pop    %ebx
  800aa8:	5e                   	pop    %esi
  800aa9:	5d                   	pop    %ebp
  800aaa:	c3                   	ret    

00800aab <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aab:	55                   	push   %ebp
  800aac:	89 e5                	mov    %esp,%ebp
  800aae:	53                   	push   %ebx
  800aaf:	83 ec 20             	sub    $0x20,%esp
  800ab2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ab5:	53                   	push   %ebx
  800ab6:	e8 e2 0b 00 00       	call   80169d <strlen>
  800abb:	83 c4 10             	add    $0x10,%esp
  800abe:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac3:	7f 67                	jg     800b2c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ac5:	83 ec 0c             	sub    $0xc,%esp
  800ac8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800acb:	50                   	push   %eax
  800acc:	e8 a1 f8 ff ff       	call   800372 <fd_alloc>
  800ad1:	83 c4 10             	add    $0x10,%esp
		return r;
  800ad4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad6:	85 c0                	test   %eax,%eax
  800ad8:	78 57                	js     800b31 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ada:	83 ec 08             	sub    $0x8,%esp
  800add:	53                   	push   %ebx
  800ade:	68 00 50 80 00       	push   $0x805000
  800ae3:	e8 ee 0b 00 00       	call   8016d6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800ae8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aeb:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af0:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af3:	b8 01 00 00 00       	mov    $0x1,%eax
  800af8:	e8 fd fd ff ff       	call   8008fa <fsipc>
  800afd:	89 c3                	mov    %eax,%ebx
  800aff:	83 c4 10             	add    $0x10,%esp
  800b02:	85 c0                	test   %eax,%eax
  800b04:	79 14                	jns    800b1a <open+0x6f>
		
		fd_close(fd, 0);
  800b06:	83 ec 08             	sub    $0x8,%esp
  800b09:	6a 00                	push   $0x0
  800b0b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b0e:	e8 57 f9 ff ff       	call   80046a <fd_close>
		return r;
  800b13:	83 c4 10             	add    $0x10,%esp
  800b16:	89 da                	mov    %ebx,%edx
  800b18:	eb 17                	jmp    800b31 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  800b1a:	83 ec 0c             	sub    $0xc,%esp
  800b1d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b20:	e8 26 f8 ff ff       	call   80034b <fd2num>
  800b25:	89 c2                	mov    %eax,%edx
  800b27:	83 c4 10             	add    $0x10,%esp
  800b2a:	eb 05                	jmp    800b31 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b2c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  800b31:	89 d0                	mov    %edx,%eax
  800b33:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b36:	c9                   	leave  
  800b37:	c3                   	ret    

00800b38 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b38:	55                   	push   %ebp
  800b39:	89 e5                	mov    %esp,%ebp
  800b3b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b3e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b43:	b8 08 00 00 00       	mov    $0x8,%eax
  800b48:	e8 ad fd ff ff       	call   8008fa <fsipc>
}
  800b4d:	c9                   	leave  
  800b4e:	c3                   	ret    

00800b4f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b4f:	55                   	push   %ebp
  800b50:	89 e5                	mov    %esp,%ebp
  800b52:	56                   	push   %esi
  800b53:	53                   	push   %ebx
  800b54:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b57:	83 ec 0c             	sub    $0xc,%esp
  800b5a:	ff 75 08             	pushl  0x8(%ebp)
  800b5d:	e8 f9 f7 ff ff       	call   80035b <fd2data>
  800b62:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b64:	83 c4 08             	add    $0x8,%esp
  800b67:	68 d7 1e 80 00       	push   $0x801ed7
  800b6c:	53                   	push   %ebx
  800b6d:	e8 64 0b 00 00       	call   8016d6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b72:	8b 46 04             	mov    0x4(%esi),%eax
  800b75:	2b 06                	sub    (%esi),%eax
  800b77:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b7d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b84:	00 00 00 
	stat->st_dev = &devpipe;
  800b87:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b8e:	30 80 00 
	return 0;
}
  800b91:	b8 00 00 00 00       	mov    $0x0,%eax
  800b96:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b99:	5b                   	pop    %ebx
  800b9a:	5e                   	pop    %esi
  800b9b:	5d                   	pop    %ebp
  800b9c:	c3                   	ret    

00800b9d <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800b9d:	55                   	push   %ebp
  800b9e:	89 e5                	mov    %esp,%ebp
  800ba0:	53                   	push   %ebx
  800ba1:	83 ec 0c             	sub    $0xc,%esp
  800ba4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800ba7:	53                   	push   %ebx
  800ba8:	6a 00                	push   $0x0
  800baa:	e8 30 f6 ff ff       	call   8001df <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800baf:	89 1c 24             	mov    %ebx,(%esp)
  800bb2:	e8 a4 f7 ff ff       	call   80035b <fd2data>
  800bb7:	83 c4 08             	add    $0x8,%esp
  800bba:	50                   	push   %eax
  800bbb:	6a 00                	push   $0x0
  800bbd:	e8 1d f6 ff ff       	call   8001df <sys_page_unmap>
}
  800bc2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc5:	c9                   	leave  
  800bc6:	c3                   	ret    

00800bc7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bc7:	55                   	push   %ebp
  800bc8:	89 e5                	mov    %esp,%ebp
  800bca:	57                   	push   %edi
  800bcb:	56                   	push   %esi
  800bcc:	53                   	push   %ebx
  800bcd:	83 ec 1c             	sub    $0x1c,%esp
  800bd0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bd3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bd5:	a1 04 40 80 00       	mov    0x804004,%eax
  800bda:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bdd:	83 ec 0c             	sub    $0xc,%esp
  800be0:	ff 75 e0             	pushl  -0x20(%ebp)
  800be3:	e8 0e 0f 00 00       	call   801af6 <pageref>
  800be8:	89 c3                	mov    %eax,%ebx
  800bea:	89 3c 24             	mov    %edi,(%esp)
  800bed:	e8 04 0f 00 00       	call   801af6 <pageref>
  800bf2:	83 c4 10             	add    $0x10,%esp
  800bf5:	39 c3                	cmp    %eax,%ebx
  800bf7:	0f 94 c1             	sete   %cl
  800bfa:	0f b6 c9             	movzbl %cl,%ecx
  800bfd:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c00:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c06:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c09:	39 ce                	cmp    %ecx,%esi
  800c0b:	74 1b                	je     800c28 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c0d:	39 c3                	cmp    %eax,%ebx
  800c0f:	75 c4                	jne    800bd5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c11:	8b 42 58             	mov    0x58(%edx),%eax
  800c14:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c17:	50                   	push   %eax
  800c18:	56                   	push   %esi
  800c19:	68 de 1e 80 00       	push   $0x801ede
  800c1e:	e8 e4 04 00 00       	call   801107 <cprintf>
  800c23:	83 c4 10             	add    $0x10,%esp
  800c26:	eb ad                	jmp    800bd5 <_pipeisclosed+0xe>
	}
}
  800c28:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c2b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c2e:	5b                   	pop    %ebx
  800c2f:	5e                   	pop    %esi
  800c30:	5f                   	pop    %edi
  800c31:	5d                   	pop    %ebp
  800c32:	c3                   	ret    

00800c33 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c33:	55                   	push   %ebp
  800c34:	89 e5                	mov    %esp,%ebp
  800c36:	57                   	push   %edi
  800c37:	56                   	push   %esi
  800c38:	53                   	push   %ebx
  800c39:	83 ec 28             	sub    $0x28,%esp
  800c3c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c3f:	56                   	push   %esi
  800c40:	e8 16 f7 ff ff       	call   80035b <fd2data>
  800c45:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c47:	83 c4 10             	add    $0x10,%esp
  800c4a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4f:	eb 4b                	jmp    800c9c <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c51:	89 da                	mov    %ebx,%edx
  800c53:	89 f0                	mov    %esi,%eax
  800c55:	e8 6d ff ff ff       	call   800bc7 <_pipeisclosed>
  800c5a:	85 c0                	test   %eax,%eax
  800c5c:	75 48                	jne    800ca6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c5e:	e8 d8 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c63:	8b 43 04             	mov    0x4(%ebx),%eax
  800c66:	8b 0b                	mov    (%ebx),%ecx
  800c68:	8d 51 20             	lea    0x20(%ecx),%edx
  800c6b:	39 d0                	cmp    %edx,%eax
  800c6d:	73 e2                	jae    800c51 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c6f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c72:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c76:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c79:	89 c2                	mov    %eax,%edx
  800c7b:	c1 fa 1f             	sar    $0x1f,%edx
  800c7e:	89 d1                	mov    %edx,%ecx
  800c80:	c1 e9 1b             	shr    $0x1b,%ecx
  800c83:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c86:	83 e2 1f             	and    $0x1f,%edx
  800c89:	29 ca                	sub    %ecx,%edx
  800c8b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c8f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c93:	83 c0 01             	add    $0x1,%eax
  800c96:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c99:	83 c7 01             	add    $0x1,%edi
  800c9c:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800c9f:	75 c2                	jne    800c63 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ca1:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca4:	eb 05                	jmp    800cab <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800ca6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cab:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cae:	5b                   	pop    %ebx
  800caf:	5e                   	pop    %esi
  800cb0:	5f                   	pop    %edi
  800cb1:	5d                   	pop    %ebp
  800cb2:	c3                   	ret    

00800cb3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cb3:	55                   	push   %ebp
  800cb4:	89 e5                	mov    %esp,%ebp
  800cb6:	57                   	push   %edi
  800cb7:	56                   	push   %esi
  800cb8:	53                   	push   %ebx
  800cb9:	83 ec 18             	sub    $0x18,%esp
  800cbc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cbf:	57                   	push   %edi
  800cc0:	e8 96 f6 ff ff       	call   80035b <fd2data>
  800cc5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cc7:	83 c4 10             	add    $0x10,%esp
  800cca:	bb 00 00 00 00       	mov    $0x0,%ebx
  800ccf:	eb 3d                	jmp    800d0e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd1:	85 db                	test   %ebx,%ebx
  800cd3:	74 04                	je     800cd9 <devpipe_read+0x26>
				return i;
  800cd5:	89 d8                	mov    %ebx,%eax
  800cd7:	eb 44                	jmp    800d1d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cd9:	89 f2                	mov    %esi,%edx
  800cdb:	89 f8                	mov    %edi,%eax
  800cdd:	e8 e5 fe ff ff       	call   800bc7 <_pipeisclosed>
  800ce2:	85 c0                	test   %eax,%eax
  800ce4:	75 32                	jne    800d18 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800ce6:	e8 50 f4 ff ff       	call   80013b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800ceb:	8b 06                	mov    (%esi),%eax
  800ced:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf0:	74 df                	je     800cd1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf2:	99                   	cltd   
  800cf3:	c1 ea 1b             	shr    $0x1b,%edx
  800cf6:	01 d0                	add    %edx,%eax
  800cf8:	83 e0 1f             	and    $0x1f,%eax
  800cfb:	29 d0                	sub    %edx,%eax
  800cfd:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d02:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d05:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d08:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0b:	83 c3 01             	add    $0x1,%ebx
  800d0e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d11:	75 d8                	jne    800ceb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d13:	8b 45 10             	mov    0x10(%ebp),%eax
  800d16:	eb 05                	jmp    800d1d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d18:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d20:	5b                   	pop    %ebx
  800d21:	5e                   	pop    %esi
  800d22:	5f                   	pop    %edi
  800d23:	5d                   	pop    %ebp
  800d24:	c3                   	ret    

00800d25 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d25:	55                   	push   %ebp
  800d26:	89 e5                	mov    %esp,%ebp
  800d28:	56                   	push   %esi
  800d29:	53                   	push   %ebx
  800d2a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d2d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d30:	50                   	push   %eax
  800d31:	e8 3c f6 ff ff       	call   800372 <fd_alloc>
  800d36:	83 c4 10             	add    $0x10,%esp
  800d39:	89 c2                	mov    %eax,%edx
  800d3b:	85 c0                	test   %eax,%eax
  800d3d:	0f 88 2c 01 00 00    	js     800e6f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d43:	83 ec 04             	sub    $0x4,%esp
  800d46:	68 07 04 00 00       	push   $0x407
  800d4b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d4e:	6a 00                	push   $0x0
  800d50:	e8 05 f4 ff ff       	call   80015a <sys_page_alloc>
  800d55:	83 c4 10             	add    $0x10,%esp
  800d58:	89 c2                	mov    %eax,%edx
  800d5a:	85 c0                	test   %eax,%eax
  800d5c:	0f 88 0d 01 00 00    	js     800e6f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d62:	83 ec 0c             	sub    $0xc,%esp
  800d65:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d68:	50                   	push   %eax
  800d69:	e8 04 f6 ff ff       	call   800372 <fd_alloc>
  800d6e:	89 c3                	mov    %eax,%ebx
  800d70:	83 c4 10             	add    $0x10,%esp
  800d73:	85 c0                	test   %eax,%eax
  800d75:	0f 88 e2 00 00 00    	js     800e5d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7b:	83 ec 04             	sub    $0x4,%esp
  800d7e:	68 07 04 00 00       	push   $0x407
  800d83:	ff 75 f0             	pushl  -0x10(%ebp)
  800d86:	6a 00                	push   $0x0
  800d88:	e8 cd f3 ff ff       	call   80015a <sys_page_alloc>
  800d8d:	89 c3                	mov    %eax,%ebx
  800d8f:	83 c4 10             	add    $0x10,%esp
  800d92:	85 c0                	test   %eax,%eax
  800d94:	0f 88 c3 00 00 00    	js     800e5d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d9a:	83 ec 0c             	sub    $0xc,%esp
  800d9d:	ff 75 f4             	pushl  -0xc(%ebp)
  800da0:	e8 b6 f5 ff ff       	call   80035b <fd2data>
  800da5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800da7:	83 c4 0c             	add    $0xc,%esp
  800daa:	68 07 04 00 00       	push   $0x407
  800daf:	50                   	push   %eax
  800db0:	6a 00                	push   $0x0
  800db2:	e8 a3 f3 ff ff       	call   80015a <sys_page_alloc>
  800db7:	89 c3                	mov    %eax,%ebx
  800db9:	83 c4 10             	add    $0x10,%esp
  800dbc:	85 c0                	test   %eax,%eax
  800dbe:	0f 88 89 00 00 00    	js     800e4d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc4:	83 ec 0c             	sub    $0xc,%esp
  800dc7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dca:	e8 8c f5 ff ff       	call   80035b <fd2data>
  800dcf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dd6:	50                   	push   %eax
  800dd7:	6a 00                	push   $0x0
  800dd9:	56                   	push   %esi
  800dda:	6a 00                	push   $0x0
  800ddc:	e8 bc f3 ff ff       	call   80019d <sys_page_map>
  800de1:	89 c3                	mov    %eax,%ebx
  800de3:	83 c4 20             	add    $0x20,%esp
  800de6:	85 c0                	test   %eax,%eax
  800de8:	78 55                	js     800e3f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dea:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df0:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df3:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800df5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df8:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800dff:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e05:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e08:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e0a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e14:	83 ec 0c             	sub    $0xc,%esp
  800e17:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1a:	e8 2c f5 ff ff       	call   80034b <fd2num>
  800e1f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e22:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e24:	83 c4 04             	add    $0x4,%esp
  800e27:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2a:	e8 1c f5 ff ff       	call   80034b <fd2num>
  800e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e32:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e35:	83 c4 10             	add    $0x10,%esp
  800e38:	ba 00 00 00 00       	mov    $0x0,%edx
  800e3d:	eb 30                	jmp    800e6f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e3f:	83 ec 08             	sub    $0x8,%esp
  800e42:	56                   	push   %esi
  800e43:	6a 00                	push   $0x0
  800e45:	e8 95 f3 ff ff       	call   8001df <sys_page_unmap>
  800e4a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e4d:	83 ec 08             	sub    $0x8,%esp
  800e50:	ff 75 f0             	pushl  -0x10(%ebp)
  800e53:	6a 00                	push   $0x0
  800e55:	e8 85 f3 ff ff       	call   8001df <sys_page_unmap>
  800e5a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	ff 75 f4             	pushl  -0xc(%ebp)
  800e63:	6a 00                	push   $0x0
  800e65:	e8 75 f3 ff ff       	call   8001df <sys_page_unmap>
  800e6a:	83 c4 10             	add    $0x10,%esp
  800e6d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e6f:	89 d0                	mov    %edx,%eax
  800e71:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e74:	5b                   	pop    %ebx
  800e75:	5e                   	pop    %esi
  800e76:	5d                   	pop    %ebp
  800e77:	c3                   	ret    

00800e78 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e78:	55                   	push   %ebp
  800e79:	89 e5                	mov    %esp,%ebp
  800e7b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e7e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e81:	50                   	push   %eax
  800e82:	ff 75 08             	pushl  0x8(%ebp)
  800e85:	e8 37 f5 ff ff       	call   8003c1 <fd_lookup>
  800e8a:	83 c4 10             	add    $0x10,%esp
  800e8d:	85 c0                	test   %eax,%eax
  800e8f:	78 18                	js     800ea9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e91:	83 ec 0c             	sub    $0xc,%esp
  800e94:	ff 75 f4             	pushl  -0xc(%ebp)
  800e97:	e8 bf f4 ff ff       	call   80035b <fd2data>
	return _pipeisclosed(fd, p);
  800e9c:	89 c2                	mov    %eax,%edx
  800e9e:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea1:	e8 21 fd ff ff       	call   800bc7 <_pipeisclosed>
  800ea6:	83 c4 10             	add    $0x10,%esp
}
  800ea9:	c9                   	leave  
  800eaa:	c3                   	ret    

00800eab <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eab:	55                   	push   %ebp
  800eac:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eae:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb3:	5d                   	pop    %ebp
  800eb4:	c3                   	ret    

00800eb5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eb5:	55                   	push   %ebp
  800eb6:	89 e5                	mov    %esp,%ebp
  800eb8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ebb:	68 f6 1e 80 00       	push   $0x801ef6
  800ec0:	ff 75 0c             	pushl  0xc(%ebp)
  800ec3:	e8 0e 08 00 00       	call   8016d6 <strcpy>
	return 0;
}
  800ec8:	b8 00 00 00 00       	mov    $0x0,%eax
  800ecd:	c9                   	leave  
  800ece:	c3                   	ret    

00800ecf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ecf:	55                   	push   %ebp
  800ed0:	89 e5                	mov    %esp,%ebp
  800ed2:	57                   	push   %edi
  800ed3:	56                   	push   %esi
  800ed4:	53                   	push   %ebx
  800ed5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800edb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee6:	eb 2d                	jmp    800f15 <devcons_write+0x46>
		m = n - tot;
  800ee8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eeb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800eed:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef0:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ef5:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef8:	83 ec 04             	sub    $0x4,%esp
  800efb:	53                   	push   %ebx
  800efc:	03 45 0c             	add    0xc(%ebp),%eax
  800eff:	50                   	push   %eax
  800f00:	57                   	push   %edi
  800f01:	e8 62 09 00 00       	call   801868 <memmove>
		sys_cputs(buf, m);
  800f06:	83 c4 08             	add    $0x8,%esp
  800f09:	53                   	push   %ebx
  800f0a:	57                   	push   %edi
  800f0b:	e8 8e f1 ff ff       	call   80009e <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f10:	01 de                	add    %ebx,%esi
  800f12:	83 c4 10             	add    $0x10,%esp
  800f15:	89 f0                	mov    %esi,%eax
  800f17:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1a:	72 cc                	jb     800ee8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f1c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f1f:	5b                   	pop    %ebx
  800f20:	5e                   	pop    %esi
  800f21:	5f                   	pop    %edi
  800f22:	5d                   	pop    %ebp
  800f23:	c3                   	ret    

00800f24 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f24:	55                   	push   %ebp
  800f25:	89 e5                	mov    %esp,%ebp
  800f27:	83 ec 08             	sub    $0x8,%esp
  800f2a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f2f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f33:	74 2a                	je     800f5f <devcons_read+0x3b>
  800f35:	eb 05                	jmp    800f3c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f37:	e8 ff f1 ff ff       	call   80013b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f3c:	e8 7b f1 ff ff       	call   8000bc <sys_cgetc>
  800f41:	85 c0                	test   %eax,%eax
  800f43:	74 f2                	je     800f37 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f45:	85 c0                	test   %eax,%eax
  800f47:	78 16                	js     800f5f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f49:	83 f8 04             	cmp    $0x4,%eax
  800f4c:	74 0c                	je     800f5a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f4e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f51:	88 02                	mov    %al,(%edx)
	return 1;
  800f53:	b8 01 00 00 00       	mov    $0x1,%eax
  800f58:	eb 05                	jmp    800f5f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f5a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f5f:	c9                   	leave  
  800f60:	c3                   	ret    

00800f61 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f61:	55                   	push   %ebp
  800f62:	89 e5                	mov    %esp,%ebp
  800f64:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f67:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f6d:	6a 01                	push   $0x1
  800f6f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f72:	50                   	push   %eax
  800f73:	e8 26 f1 ff ff       	call   80009e <sys_cputs>
}
  800f78:	83 c4 10             	add    $0x10,%esp
  800f7b:	c9                   	leave  
  800f7c:	c3                   	ret    

00800f7d <getchar>:

int
getchar(void)
{
  800f7d:	55                   	push   %ebp
  800f7e:	89 e5                	mov    %esp,%ebp
  800f80:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f83:	6a 01                	push   $0x1
  800f85:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f88:	50                   	push   %eax
  800f89:	6a 00                	push   $0x0
  800f8b:	e8 97 f6 ff ff       	call   800627 <read>
	if (r < 0)
  800f90:	83 c4 10             	add    $0x10,%esp
  800f93:	85 c0                	test   %eax,%eax
  800f95:	78 0f                	js     800fa6 <getchar+0x29>
		return r;
	if (r < 1)
  800f97:	85 c0                	test   %eax,%eax
  800f99:	7e 06                	jle    800fa1 <getchar+0x24>
		return -E_EOF;
	return c;
  800f9b:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800f9f:	eb 05                	jmp    800fa6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fa1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fa6:	c9                   	leave  
  800fa7:	c3                   	ret    

00800fa8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fa8:	55                   	push   %ebp
  800fa9:	89 e5                	mov    %esp,%ebp
  800fab:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fae:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb1:	50                   	push   %eax
  800fb2:	ff 75 08             	pushl  0x8(%ebp)
  800fb5:	e8 07 f4 ff ff       	call   8003c1 <fd_lookup>
  800fba:	83 c4 10             	add    $0x10,%esp
  800fbd:	85 c0                	test   %eax,%eax
  800fbf:	78 11                	js     800fd2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fc1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc4:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fca:	39 10                	cmp    %edx,(%eax)
  800fcc:	0f 94 c0             	sete   %al
  800fcf:	0f b6 c0             	movzbl %al,%eax
}
  800fd2:	c9                   	leave  
  800fd3:	c3                   	ret    

00800fd4 <opencons>:

int
opencons(void)
{
  800fd4:	55                   	push   %ebp
  800fd5:	89 e5                	mov    %esp,%ebp
  800fd7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fda:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fdd:	50                   	push   %eax
  800fde:	e8 8f f3 ff ff       	call   800372 <fd_alloc>
  800fe3:	83 c4 10             	add    $0x10,%esp
		return r;
  800fe6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe8:	85 c0                	test   %eax,%eax
  800fea:	78 3e                	js     80102a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800fec:	83 ec 04             	sub    $0x4,%esp
  800fef:	68 07 04 00 00       	push   $0x407
  800ff4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ff7:	6a 00                	push   $0x0
  800ff9:	e8 5c f1 ff ff       	call   80015a <sys_page_alloc>
  800ffe:	83 c4 10             	add    $0x10,%esp
		return r;
  801001:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801003:	85 c0                	test   %eax,%eax
  801005:	78 23                	js     80102a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801007:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  80100d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801010:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801012:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801015:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80101c:	83 ec 0c             	sub    $0xc,%esp
  80101f:	50                   	push   %eax
  801020:	e8 26 f3 ff ff       	call   80034b <fd2num>
  801025:	89 c2                	mov    %eax,%edx
  801027:	83 c4 10             	add    $0x10,%esp
}
  80102a:	89 d0                	mov    %edx,%eax
  80102c:	c9                   	leave  
  80102d:	c3                   	ret    

0080102e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80102e:	55                   	push   %ebp
  80102f:	89 e5                	mov    %esp,%ebp
  801031:	56                   	push   %esi
  801032:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801033:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801036:	8b 35 00 30 80 00    	mov    0x803000,%esi
  80103c:	e8 db f0 ff ff       	call   80011c <sys_getenvid>
  801041:	83 ec 0c             	sub    $0xc,%esp
  801044:	ff 75 0c             	pushl  0xc(%ebp)
  801047:	ff 75 08             	pushl  0x8(%ebp)
  80104a:	56                   	push   %esi
  80104b:	50                   	push   %eax
  80104c:	68 04 1f 80 00       	push   $0x801f04
  801051:	e8 b1 00 00 00       	call   801107 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801056:	83 c4 18             	add    $0x18,%esp
  801059:	53                   	push   %ebx
  80105a:	ff 75 10             	pushl  0x10(%ebp)
  80105d:	e8 54 00 00 00       	call   8010b6 <vcprintf>
	cprintf("\n");
  801062:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  801069:	e8 99 00 00 00       	call   801107 <cprintf>
  80106e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801071:	cc                   	int3   
  801072:	eb fd                	jmp    801071 <_panic+0x43>

00801074 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801074:	55                   	push   %ebp
  801075:	89 e5                	mov    %esp,%ebp
  801077:	53                   	push   %ebx
  801078:	83 ec 04             	sub    $0x4,%esp
  80107b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80107e:	8b 13                	mov    (%ebx),%edx
  801080:	8d 42 01             	lea    0x1(%edx),%eax
  801083:	89 03                	mov    %eax,(%ebx)
  801085:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801088:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80108c:	3d ff 00 00 00       	cmp    $0xff,%eax
  801091:	75 1a                	jne    8010ad <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801093:	83 ec 08             	sub    $0x8,%esp
  801096:	68 ff 00 00 00       	push   $0xff
  80109b:	8d 43 08             	lea    0x8(%ebx),%eax
  80109e:	50                   	push   %eax
  80109f:	e8 fa ef ff ff       	call   80009e <sys_cputs>
		b->idx = 0;
  8010a4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010aa:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010ad:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b4:	c9                   	leave  
  8010b5:	c3                   	ret    

008010b6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010b6:	55                   	push   %ebp
  8010b7:	89 e5                	mov    %esp,%ebp
  8010b9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8010bf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010c6:	00 00 00 
	b.cnt = 0;
  8010c9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d3:	ff 75 0c             	pushl  0xc(%ebp)
  8010d6:	ff 75 08             	pushl  0x8(%ebp)
  8010d9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010df:	50                   	push   %eax
  8010e0:	68 74 10 80 00       	push   $0x801074
  8010e5:	e8 54 01 00 00       	call   80123e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ea:	83 c4 08             	add    $0x8,%esp
  8010ed:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f3:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010f9:	50                   	push   %eax
  8010fa:	e8 9f ef ff ff       	call   80009e <sys_cputs>

	return b.cnt;
}
  8010ff:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801105:	c9                   	leave  
  801106:	c3                   	ret    

00801107 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801107:	55                   	push   %ebp
  801108:	89 e5                	mov    %esp,%ebp
  80110a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80110d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801110:	50                   	push   %eax
  801111:	ff 75 08             	pushl  0x8(%ebp)
  801114:	e8 9d ff ff ff       	call   8010b6 <vcprintf>
	va_end(ap);

	return cnt;
}
  801119:	c9                   	leave  
  80111a:	c3                   	ret    

0080111b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80111b:	55                   	push   %ebp
  80111c:	89 e5                	mov    %esp,%ebp
  80111e:	57                   	push   %edi
  80111f:	56                   	push   %esi
  801120:	53                   	push   %ebx
  801121:	83 ec 1c             	sub    $0x1c,%esp
  801124:	89 c7                	mov    %eax,%edi
  801126:	89 d6                	mov    %edx,%esi
  801128:	8b 45 08             	mov    0x8(%ebp),%eax
  80112b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80112e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801131:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801134:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801137:	bb 00 00 00 00       	mov    $0x0,%ebx
  80113c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80113f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801142:	39 d3                	cmp    %edx,%ebx
  801144:	72 05                	jb     80114b <printnum+0x30>
  801146:	39 45 10             	cmp    %eax,0x10(%ebp)
  801149:	77 45                	ja     801190 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80114b:	83 ec 0c             	sub    $0xc,%esp
  80114e:	ff 75 18             	pushl  0x18(%ebp)
  801151:	8b 45 14             	mov    0x14(%ebp),%eax
  801154:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801157:	53                   	push   %ebx
  801158:	ff 75 10             	pushl  0x10(%ebp)
  80115b:	83 ec 08             	sub    $0x8,%esp
  80115e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801161:	ff 75 e0             	pushl  -0x20(%ebp)
  801164:	ff 75 dc             	pushl  -0x24(%ebp)
  801167:	ff 75 d8             	pushl  -0x28(%ebp)
  80116a:	e8 d1 09 00 00       	call   801b40 <__udivdi3>
  80116f:	83 c4 18             	add    $0x18,%esp
  801172:	52                   	push   %edx
  801173:	50                   	push   %eax
  801174:	89 f2                	mov    %esi,%edx
  801176:	89 f8                	mov    %edi,%eax
  801178:	e8 9e ff ff ff       	call   80111b <printnum>
  80117d:	83 c4 20             	add    $0x20,%esp
  801180:	eb 18                	jmp    80119a <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801182:	83 ec 08             	sub    $0x8,%esp
  801185:	56                   	push   %esi
  801186:	ff 75 18             	pushl  0x18(%ebp)
  801189:	ff d7                	call   *%edi
  80118b:	83 c4 10             	add    $0x10,%esp
  80118e:	eb 03                	jmp    801193 <printnum+0x78>
  801190:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801193:	83 eb 01             	sub    $0x1,%ebx
  801196:	85 db                	test   %ebx,%ebx
  801198:	7f e8                	jg     801182 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80119a:	83 ec 08             	sub    $0x8,%esp
  80119d:	56                   	push   %esi
  80119e:	83 ec 04             	sub    $0x4,%esp
  8011a1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011a7:	ff 75 dc             	pushl  -0x24(%ebp)
  8011aa:	ff 75 d8             	pushl  -0x28(%ebp)
  8011ad:	e8 be 0a 00 00       	call   801c70 <__umoddi3>
  8011b2:	83 c4 14             	add    $0x14,%esp
  8011b5:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  8011bc:	50                   	push   %eax
  8011bd:	ff d7                	call   *%edi
}
  8011bf:	83 c4 10             	add    $0x10,%esp
  8011c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c5:	5b                   	pop    %ebx
  8011c6:	5e                   	pop    %esi
  8011c7:	5f                   	pop    %edi
  8011c8:	5d                   	pop    %ebp
  8011c9:	c3                   	ret    

008011ca <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011ca:	55                   	push   %ebp
  8011cb:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011cd:	83 fa 01             	cmp    $0x1,%edx
  8011d0:	7e 0e                	jle    8011e0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011d2:	8b 10                	mov    (%eax),%edx
  8011d4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011d7:	89 08                	mov    %ecx,(%eax)
  8011d9:	8b 02                	mov    (%edx),%eax
  8011db:	8b 52 04             	mov    0x4(%edx),%edx
  8011de:	eb 22                	jmp    801202 <getuint+0x38>
	else if (lflag)
  8011e0:	85 d2                	test   %edx,%edx
  8011e2:	74 10                	je     8011f4 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011e4:	8b 10                	mov    (%eax),%edx
  8011e6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011e9:	89 08                	mov    %ecx,(%eax)
  8011eb:	8b 02                	mov    (%edx),%eax
  8011ed:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f2:	eb 0e                	jmp    801202 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011f4:	8b 10                	mov    (%eax),%edx
  8011f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f9:	89 08                	mov    %ecx,(%eax)
  8011fb:	8b 02                	mov    (%edx),%eax
  8011fd:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801202:	5d                   	pop    %ebp
  801203:	c3                   	ret    

00801204 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801204:	55                   	push   %ebp
  801205:	89 e5                	mov    %esp,%ebp
  801207:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80120a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80120e:	8b 10                	mov    (%eax),%edx
  801210:	3b 50 04             	cmp    0x4(%eax),%edx
  801213:	73 0a                	jae    80121f <sprintputch+0x1b>
		*b->buf++ = ch;
  801215:	8d 4a 01             	lea    0x1(%edx),%ecx
  801218:	89 08                	mov    %ecx,(%eax)
  80121a:	8b 45 08             	mov    0x8(%ebp),%eax
  80121d:	88 02                	mov    %al,(%edx)
}
  80121f:	5d                   	pop    %ebp
  801220:	c3                   	ret    

00801221 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801221:	55                   	push   %ebp
  801222:	89 e5                	mov    %esp,%ebp
  801224:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801227:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80122a:	50                   	push   %eax
  80122b:	ff 75 10             	pushl  0x10(%ebp)
  80122e:	ff 75 0c             	pushl  0xc(%ebp)
  801231:	ff 75 08             	pushl  0x8(%ebp)
  801234:	e8 05 00 00 00       	call   80123e <vprintfmt>
	va_end(ap);
}
  801239:	83 c4 10             	add    $0x10,%esp
  80123c:	c9                   	leave  
  80123d:	c3                   	ret    

0080123e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80123e:	55                   	push   %ebp
  80123f:	89 e5                	mov    %esp,%ebp
  801241:	57                   	push   %edi
  801242:	56                   	push   %esi
  801243:	53                   	push   %ebx
  801244:	83 ec 2c             	sub    $0x2c,%esp
  801247:	8b 75 08             	mov    0x8(%ebp),%esi
  80124a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80124d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801250:	eb 12                	jmp    801264 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801252:	85 c0                	test   %eax,%eax
  801254:	0f 84 d3 03 00 00    	je     80162d <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80125a:	83 ec 08             	sub    $0x8,%esp
  80125d:	53                   	push   %ebx
  80125e:	50                   	push   %eax
  80125f:	ff d6                	call   *%esi
  801261:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801264:	83 c7 01             	add    $0x1,%edi
  801267:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80126b:	83 f8 25             	cmp    $0x25,%eax
  80126e:	75 e2                	jne    801252 <vprintfmt+0x14>
  801270:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801274:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80127b:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801282:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801289:	ba 00 00 00 00       	mov    $0x0,%edx
  80128e:	eb 07                	jmp    801297 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801290:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801293:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801297:	8d 47 01             	lea    0x1(%edi),%eax
  80129a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  80129d:	0f b6 07             	movzbl (%edi),%eax
  8012a0:	0f b6 c8             	movzbl %al,%ecx
  8012a3:	83 e8 23             	sub    $0x23,%eax
  8012a6:	3c 55                	cmp    $0x55,%al
  8012a8:	0f 87 64 03 00 00    	ja     801612 <vprintfmt+0x3d4>
  8012ae:	0f b6 c0             	movzbl %al,%eax
  8012b1:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  8012b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012bb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012bf:	eb d6                	jmp    801297 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012c4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012c9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012cc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012cf:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012d3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012d6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012d9:	83 fa 09             	cmp    $0x9,%edx
  8012dc:	77 39                	ja     801317 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012de:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012e1:	eb e9                	jmp    8012cc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012e3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012e6:	8d 48 04             	lea    0x4(%eax),%ecx
  8012e9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012ec:	8b 00                	mov    (%eax),%eax
  8012ee:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012f4:	eb 27                	jmp    80131d <vprintfmt+0xdf>
  8012f6:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012f9:	85 c0                	test   %eax,%eax
  8012fb:	b9 00 00 00 00       	mov    $0x0,%ecx
  801300:	0f 49 c8             	cmovns %eax,%ecx
  801303:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801306:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801309:	eb 8c                	jmp    801297 <vprintfmt+0x59>
  80130b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80130e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801315:	eb 80                	jmp    801297 <vprintfmt+0x59>
  801317:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80131a:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80131d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801321:	0f 89 70 ff ff ff    	jns    801297 <vprintfmt+0x59>
				width = precision, precision = -1;
  801327:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80132a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80132d:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801334:	e9 5e ff ff ff       	jmp    801297 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801339:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80133c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80133f:	e9 53 ff ff ff       	jmp    801297 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801344:	8b 45 14             	mov    0x14(%ebp),%eax
  801347:	8d 50 04             	lea    0x4(%eax),%edx
  80134a:	89 55 14             	mov    %edx,0x14(%ebp)
  80134d:	83 ec 08             	sub    $0x8,%esp
  801350:	53                   	push   %ebx
  801351:	ff 30                	pushl  (%eax)
  801353:	ff d6                	call   *%esi
			break;
  801355:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801358:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80135b:	e9 04 ff ff ff       	jmp    801264 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801360:	8b 45 14             	mov    0x14(%ebp),%eax
  801363:	8d 50 04             	lea    0x4(%eax),%edx
  801366:	89 55 14             	mov    %edx,0x14(%ebp)
  801369:	8b 00                	mov    (%eax),%eax
  80136b:	99                   	cltd   
  80136c:	31 d0                	xor    %edx,%eax
  80136e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801370:	83 f8 0f             	cmp    $0xf,%eax
  801373:	7f 0b                	jg     801380 <vprintfmt+0x142>
  801375:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  80137c:	85 d2                	test   %edx,%edx
  80137e:	75 18                	jne    801398 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801380:	50                   	push   %eax
  801381:	68 3f 1f 80 00       	push   $0x801f3f
  801386:	53                   	push   %ebx
  801387:	56                   	push   %esi
  801388:	e8 94 fe ff ff       	call   801221 <printfmt>
  80138d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801390:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801393:	e9 cc fe ff ff       	jmp    801264 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  801398:	52                   	push   %edx
  801399:	68 bd 1e 80 00       	push   $0x801ebd
  80139e:	53                   	push   %ebx
  80139f:	56                   	push   %esi
  8013a0:	e8 7c fe ff ff       	call   801221 <printfmt>
  8013a5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013ab:	e9 b4 fe ff ff       	jmp    801264 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b3:	8d 50 04             	lea    0x4(%eax),%edx
  8013b6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013b9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013bb:	85 ff                	test   %edi,%edi
  8013bd:	b8 38 1f 80 00       	mov    $0x801f38,%eax
  8013c2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013c5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013c9:	0f 8e 94 00 00 00    	jle    801463 <vprintfmt+0x225>
  8013cf:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013d3:	0f 84 98 00 00 00    	je     801471 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013d9:	83 ec 08             	sub    $0x8,%esp
  8013dc:	ff 75 c8             	pushl  -0x38(%ebp)
  8013df:	57                   	push   %edi
  8013e0:	e8 d0 02 00 00       	call   8016b5 <strnlen>
  8013e5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013e8:	29 c1                	sub    %eax,%ecx
  8013ea:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8013ed:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013f0:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013f4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013f7:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013fa:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8013fc:	eb 0f                	jmp    80140d <vprintfmt+0x1cf>
					putch(padc, putdat);
  8013fe:	83 ec 08             	sub    $0x8,%esp
  801401:	53                   	push   %ebx
  801402:	ff 75 e0             	pushl  -0x20(%ebp)
  801405:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801407:	83 ef 01             	sub    $0x1,%edi
  80140a:	83 c4 10             	add    $0x10,%esp
  80140d:	85 ff                	test   %edi,%edi
  80140f:	7f ed                	jg     8013fe <vprintfmt+0x1c0>
  801411:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801414:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801417:	85 c9                	test   %ecx,%ecx
  801419:	b8 00 00 00 00       	mov    $0x0,%eax
  80141e:	0f 49 c1             	cmovns %ecx,%eax
  801421:	29 c1                	sub    %eax,%ecx
  801423:	89 75 08             	mov    %esi,0x8(%ebp)
  801426:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801429:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80142c:	89 cb                	mov    %ecx,%ebx
  80142e:	eb 4d                	jmp    80147d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801430:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801434:	74 1b                	je     801451 <vprintfmt+0x213>
  801436:	0f be c0             	movsbl %al,%eax
  801439:	83 e8 20             	sub    $0x20,%eax
  80143c:	83 f8 5e             	cmp    $0x5e,%eax
  80143f:	76 10                	jbe    801451 <vprintfmt+0x213>
					putch('?', putdat);
  801441:	83 ec 08             	sub    $0x8,%esp
  801444:	ff 75 0c             	pushl  0xc(%ebp)
  801447:	6a 3f                	push   $0x3f
  801449:	ff 55 08             	call   *0x8(%ebp)
  80144c:	83 c4 10             	add    $0x10,%esp
  80144f:	eb 0d                	jmp    80145e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	ff 75 0c             	pushl  0xc(%ebp)
  801457:	52                   	push   %edx
  801458:	ff 55 08             	call   *0x8(%ebp)
  80145b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80145e:	83 eb 01             	sub    $0x1,%ebx
  801461:	eb 1a                	jmp    80147d <vprintfmt+0x23f>
  801463:	89 75 08             	mov    %esi,0x8(%ebp)
  801466:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801469:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80146c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80146f:	eb 0c                	jmp    80147d <vprintfmt+0x23f>
  801471:	89 75 08             	mov    %esi,0x8(%ebp)
  801474:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801477:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80147d:	83 c7 01             	add    $0x1,%edi
  801480:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801484:	0f be d0             	movsbl %al,%edx
  801487:	85 d2                	test   %edx,%edx
  801489:	74 23                	je     8014ae <vprintfmt+0x270>
  80148b:	85 f6                	test   %esi,%esi
  80148d:	78 a1                	js     801430 <vprintfmt+0x1f2>
  80148f:	83 ee 01             	sub    $0x1,%esi
  801492:	79 9c                	jns    801430 <vprintfmt+0x1f2>
  801494:	89 df                	mov    %ebx,%edi
  801496:	8b 75 08             	mov    0x8(%ebp),%esi
  801499:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80149c:	eb 18                	jmp    8014b6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  80149e:	83 ec 08             	sub    $0x8,%esp
  8014a1:	53                   	push   %ebx
  8014a2:	6a 20                	push   $0x20
  8014a4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014a6:	83 ef 01             	sub    $0x1,%edi
  8014a9:	83 c4 10             	add    $0x10,%esp
  8014ac:	eb 08                	jmp    8014b6 <vprintfmt+0x278>
  8014ae:	89 df                	mov    %ebx,%edi
  8014b0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014b6:	85 ff                	test   %edi,%edi
  8014b8:	7f e4                	jg     80149e <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ba:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014bd:	e9 a2 fd ff ff       	jmp    801264 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014c2:	83 fa 01             	cmp    $0x1,%edx
  8014c5:	7e 16                	jle    8014dd <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014c7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ca:	8d 50 08             	lea    0x8(%eax),%edx
  8014cd:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d0:	8b 50 04             	mov    0x4(%eax),%edx
  8014d3:	8b 00                	mov    (%eax),%eax
  8014d5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8014d8:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8014db:	eb 32                	jmp    80150f <vprintfmt+0x2d1>
	else if (lflag)
  8014dd:	85 d2                	test   %edx,%edx
  8014df:	74 18                	je     8014f9 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014e1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e4:	8d 50 04             	lea    0x4(%eax),%edx
  8014e7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ea:	8b 00                	mov    (%eax),%eax
  8014ec:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8014ef:	89 c1                	mov    %eax,%ecx
  8014f1:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f4:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8014f7:	eb 16                	jmp    80150f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014f9:	8b 45 14             	mov    0x14(%ebp),%eax
  8014fc:	8d 50 04             	lea    0x4(%eax),%edx
  8014ff:	89 55 14             	mov    %edx,0x14(%ebp)
  801502:	8b 00                	mov    (%eax),%eax
  801504:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801507:	89 c1                	mov    %eax,%ecx
  801509:	c1 f9 1f             	sar    $0x1f,%ecx
  80150c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80150f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801512:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801515:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801518:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80151b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801520:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801524:	0f 89 b0 00 00 00    	jns    8015da <vprintfmt+0x39c>
				putch('-', putdat);
  80152a:	83 ec 08             	sub    $0x8,%esp
  80152d:	53                   	push   %ebx
  80152e:	6a 2d                	push   $0x2d
  801530:	ff d6                	call   *%esi
				num = -(long long) num;
  801532:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801535:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801538:	f7 d8                	neg    %eax
  80153a:	83 d2 00             	adc    $0x0,%edx
  80153d:	f7 da                	neg    %edx
  80153f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801542:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801545:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801548:	b8 0a 00 00 00       	mov    $0xa,%eax
  80154d:	e9 88 00 00 00       	jmp    8015da <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801552:	8d 45 14             	lea    0x14(%ebp),%eax
  801555:	e8 70 fc ff ff       	call   8011ca <getuint>
  80155a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80155d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  801560:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801565:	eb 73                	jmp    8015da <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  801567:	8d 45 14             	lea    0x14(%ebp),%eax
  80156a:	e8 5b fc ff ff       	call   8011ca <getuint>
  80156f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801572:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  801575:	83 ec 08             	sub    $0x8,%esp
  801578:	53                   	push   %ebx
  801579:	6a 58                	push   $0x58
  80157b:	ff d6                	call   *%esi
			putch('X', putdat);
  80157d:	83 c4 08             	add    $0x8,%esp
  801580:	53                   	push   %ebx
  801581:	6a 58                	push   $0x58
  801583:	ff d6                	call   *%esi
			putch('X', putdat);
  801585:	83 c4 08             	add    $0x8,%esp
  801588:	53                   	push   %ebx
  801589:	6a 58                	push   $0x58
  80158b:	ff d6                	call   *%esi
			goto number;
  80158d:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  801590:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  801595:	eb 43                	jmp    8015da <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  801597:	83 ec 08             	sub    $0x8,%esp
  80159a:	53                   	push   %ebx
  80159b:	6a 30                	push   $0x30
  80159d:	ff d6                	call   *%esi
			putch('x', putdat);
  80159f:	83 c4 08             	add    $0x8,%esp
  8015a2:	53                   	push   %ebx
  8015a3:	6a 78                	push   $0x78
  8015a5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015a7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015aa:	8d 50 04             	lea    0x4(%eax),%edx
  8015ad:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015b0:	8b 00                	mov    (%eax),%eax
  8015b2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015b7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ba:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015bd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015c0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015c5:	eb 13                	jmp    8015da <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015c7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ca:	e8 fb fb ff ff       	call   8011ca <getuint>
  8015cf:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015d2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8015d5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015da:	83 ec 0c             	sub    $0xc,%esp
  8015dd:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8015e1:	52                   	push   %edx
  8015e2:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e5:	50                   	push   %eax
  8015e6:	ff 75 dc             	pushl  -0x24(%ebp)
  8015e9:	ff 75 d8             	pushl  -0x28(%ebp)
  8015ec:	89 da                	mov    %ebx,%edx
  8015ee:	89 f0                	mov    %esi,%eax
  8015f0:	e8 26 fb ff ff       	call   80111b <printnum>
			break;
  8015f5:	83 c4 20             	add    $0x20,%esp
  8015f8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015fb:	e9 64 fc ff ff       	jmp    801264 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801600:	83 ec 08             	sub    $0x8,%esp
  801603:	53                   	push   %ebx
  801604:	51                   	push   %ecx
  801605:	ff d6                	call   *%esi
			break;
  801607:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80160d:	e9 52 fc ff ff       	jmp    801264 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801612:	83 ec 08             	sub    $0x8,%esp
  801615:	53                   	push   %ebx
  801616:	6a 25                	push   $0x25
  801618:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80161a:	83 c4 10             	add    $0x10,%esp
  80161d:	eb 03                	jmp    801622 <vprintfmt+0x3e4>
  80161f:	83 ef 01             	sub    $0x1,%edi
  801622:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801626:	75 f7                	jne    80161f <vprintfmt+0x3e1>
  801628:	e9 37 fc ff ff       	jmp    801264 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80162d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801630:	5b                   	pop    %ebx
  801631:	5e                   	pop    %esi
  801632:	5f                   	pop    %edi
  801633:	5d                   	pop    %ebp
  801634:	c3                   	ret    

00801635 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801635:	55                   	push   %ebp
  801636:	89 e5                	mov    %esp,%ebp
  801638:	83 ec 18             	sub    $0x18,%esp
  80163b:	8b 45 08             	mov    0x8(%ebp),%eax
  80163e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801641:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801644:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801648:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80164b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801652:	85 c0                	test   %eax,%eax
  801654:	74 26                	je     80167c <vsnprintf+0x47>
  801656:	85 d2                	test   %edx,%edx
  801658:	7e 22                	jle    80167c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80165a:	ff 75 14             	pushl  0x14(%ebp)
  80165d:	ff 75 10             	pushl  0x10(%ebp)
  801660:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801663:	50                   	push   %eax
  801664:	68 04 12 80 00       	push   $0x801204
  801669:	e8 d0 fb ff ff       	call   80123e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80166e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801671:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801674:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801677:	83 c4 10             	add    $0x10,%esp
  80167a:	eb 05                	jmp    801681 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80167c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801681:	c9                   	leave  
  801682:	c3                   	ret    

00801683 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801683:	55                   	push   %ebp
  801684:	89 e5                	mov    %esp,%ebp
  801686:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801689:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80168c:	50                   	push   %eax
  80168d:	ff 75 10             	pushl  0x10(%ebp)
  801690:	ff 75 0c             	pushl  0xc(%ebp)
  801693:	ff 75 08             	pushl  0x8(%ebp)
  801696:	e8 9a ff ff ff       	call   801635 <vsnprintf>
	va_end(ap);

	return rc;
}
  80169b:	c9                   	leave  
  80169c:	c3                   	ret    

0080169d <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  80169d:	55                   	push   %ebp
  80169e:	89 e5                	mov    %esp,%ebp
  8016a0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016a3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016a8:	eb 03                	jmp    8016ad <strlen+0x10>
		n++;
  8016aa:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ad:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016b1:	75 f7                	jne    8016aa <strlen+0xd>
		n++;
	return n;
}
  8016b3:	5d                   	pop    %ebp
  8016b4:	c3                   	ret    

008016b5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016b5:	55                   	push   %ebp
  8016b6:	89 e5                	mov    %esp,%ebp
  8016b8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016bb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016be:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c3:	eb 03                	jmp    8016c8 <strnlen+0x13>
		n++;
  8016c5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c8:	39 c2                	cmp    %eax,%edx
  8016ca:	74 08                	je     8016d4 <strnlen+0x1f>
  8016cc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016d0:	75 f3                	jne    8016c5 <strnlen+0x10>
  8016d2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016d4:	5d                   	pop    %ebp
  8016d5:	c3                   	ret    

008016d6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016d6:	55                   	push   %ebp
  8016d7:	89 e5                	mov    %esp,%ebp
  8016d9:	53                   	push   %ebx
  8016da:	8b 45 08             	mov    0x8(%ebp),%eax
  8016dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e0:	89 c2                	mov    %eax,%edx
  8016e2:	83 c2 01             	add    $0x1,%edx
  8016e5:	83 c1 01             	add    $0x1,%ecx
  8016e8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016ec:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016ef:	84 db                	test   %bl,%bl
  8016f1:	75 ef                	jne    8016e2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016f3:	5b                   	pop    %ebx
  8016f4:	5d                   	pop    %ebp
  8016f5:	c3                   	ret    

008016f6 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016f6:	55                   	push   %ebp
  8016f7:	89 e5                	mov    %esp,%ebp
  8016f9:	53                   	push   %ebx
  8016fa:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8016fd:	53                   	push   %ebx
  8016fe:	e8 9a ff ff ff       	call   80169d <strlen>
  801703:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801706:	ff 75 0c             	pushl  0xc(%ebp)
  801709:	01 d8                	add    %ebx,%eax
  80170b:	50                   	push   %eax
  80170c:	e8 c5 ff ff ff       	call   8016d6 <strcpy>
	return dst;
}
  801711:	89 d8                	mov    %ebx,%eax
  801713:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801716:	c9                   	leave  
  801717:	c3                   	ret    

00801718 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801718:	55                   	push   %ebp
  801719:	89 e5                	mov    %esp,%ebp
  80171b:	56                   	push   %esi
  80171c:	53                   	push   %ebx
  80171d:	8b 75 08             	mov    0x8(%ebp),%esi
  801720:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801723:	89 f3                	mov    %esi,%ebx
  801725:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801728:	89 f2                	mov    %esi,%edx
  80172a:	eb 0f                	jmp    80173b <strncpy+0x23>
		*dst++ = *src;
  80172c:	83 c2 01             	add    $0x1,%edx
  80172f:	0f b6 01             	movzbl (%ecx),%eax
  801732:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801735:	80 39 01             	cmpb   $0x1,(%ecx)
  801738:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173b:	39 da                	cmp    %ebx,%edx
  80173d:	75 ed                	jne    80172c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80173f:	89 f0                	mov    %esi,%eax
  801741:	5b                   	pop    %ebx
  801742:	5e                   	pop    %esi
  801743:	5d                   	pop    %ebp
  801744:	c3                   	ret    

00801745 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801745:	55                   	push   %ebp
  801746:	89 e5                	mov    %esp,%ebp
  801748:	56                   	push   %esi
  801749:	53                   	push   %ebx
  80174a:	8b 75 08             	mov    0x8(%ebp),%esi
  80174d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801750:	8b 55 10             	mov    0x10(%ebp),%edx
  801753:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801755:	85 d2                	test   %edx,%edx
  801757:	74 21                	je     80177a <strlcpy+0x35>
  801759:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80175d:	89 f2                	mov    %esi,%edx
  80175f:	eb 09                	jmp    80176a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801761:	83 c2 01             	add    $0x1,%edx
  801764:	83 c1 01             	add    $0x1,%ecx
  801767:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80176a:	39 c2                	cmp    %eax,%edx
  80176c:	74 09                	je     801777 <strlcpy+0x32>
  80176e:	0f b6 19             	movzbl (%ecx),%ebx
  801771:	84 db                	test   %bl,%bl
  801773:	75 ec                	jne    801761 <strlcpy+0x1c>
  801775:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801777:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80177a:	29 f0                	sub    %esi,%eax
}
  80177c:	5b                   	pop    %ebx
  80177d:	5e                   	pop    %esi
  80177e:	5d                   	pop    %ebp
  80177f:	c3                   	ret    

00801780 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801780:	55                   	push   %ebp
  801781:	89 e5                	mov    %esp,%ebp
  801783:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801786:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801789:	eb 06                	jmp    801791 <strcmp+0x11>
		p++, q++;
  80178b:	83 c1 01             	add    $0x1,%ecx
  80178e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801791:	0f b6 01             	movzbl (%ecx),%eax
  801794:	84 c0                	test   %al,%al
  801796:	74 04                	je     80179c <strcmp+0x1c>
  801798:	3a 02                	cmp    (%edx),%al
  80179a:	74 ef                	je     80178b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  80179c:	0f b6 c0             	movzbl %al,%eax
  80179f:	0f b6 12             	movzbl (%edx),%edx
  8017a2:	29 d0                	sub    %edx,%eax
}
  8017a4:	5d                   	pop    %ebp
  8017a5:	c3                   	ret    

008017a6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017a6:	55                   	push   %ebp
  8017a7:	89 e5                	mov    %esp,%ebp
  8017a9:	53                   	push   %ebx
  8017aa:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b0:	89 c3                	mov    %eax,%ebx
  8017b2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017b5:	eb 06                	jmp    8017bd <strncmp+0x17>
		n--, p++, q++;
  8017b7:	83 c0 01             	add    $0x1,%eax
  8017ba:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017bd:	39 d8                	cmp    %ebx,%eax
  8017bf:	74 15                	je     8017d6 <strncmp+0x30>
  8017c1:	0f b6 08             	movzbl (%eax),%ecx
  8017c4:	84 c9                	test   %cl,%cl
  8017c6:	74 04                	je     8017cc <strncmp+0x26>
  8017c8:	3a 0a                	cmp    (%edx),%cl
  8017ca:	74 eb                	je     8017b7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017cc:	0f b6 00             	movzbl (%eax),%eax
  8017cf:	0f b6 12             	movzbl (%edx),%edx
  8017d2:	29 d0                	sub    %edx,%eax
  8017d4:	eb 05                	jmp    8017db <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017d6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017db:	5b                   	pop    %ebx
  8017dc:	5d                   	pop    %ebp
  8017dd:	c3                   	ret    

008017de <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017de:	55                   	push   %ebp
  8017df:	89 e5                	mov    %esp,%ebp
  8017e1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017e8:	eb 07                	jmp    8017f1 <strchr+0x13>
		if (*s == c)
  8017ea:	38 ca                	cmp    %cl,%dl
  8017ec:	74 0f                	je     8017fd <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017ee:	83 c0 01             	add    $0x1,%eax
  8017f1:	0f b6 10             	movzbl (%eax),%edx
  8017f4:	84 d2                	test   %dl,%dl
  8017f6:	75 f2                	jne    8017ea <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017f8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8017fd:	5d                   	pop    %ebp
  8017fe:	c3                   	ret    

008017ff <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  8017ff:	55                   	push   %ebp
  801800:	89 e5                	mov    %esp,%ebp
  801802:	8b 45 08             	mov    0x8(%ebp),%eax
  801805:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801809:	eb 03                	jmp    80180e <strfind+0xf>
  80180b:	83 c0 01             	add    $0x1,%eax
  80180e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801811:	38 ca                	cmp    %cl,%dl
  801813:	74 04                	je     801819 <strfind+0x1a>
  801815:	84 d2                	test   %dl,%dl
  801817:	75 f2                	jne    80180b <strfind+0xc>
			break;
	return (char *) s;
}
  801819:	5d                   	pop    %ebp
  80181a:	c3                   	ret    

0080181b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80181b:	55                   	push   %ebp
  80181c:	89 e5                	mov    %esp,%ebp
  80181e:	57                   	push   %edi
  80181f:	56                   	push   %esi
  801820:	53                   	push   %ebx
  801821:	8b 7d 08             	mov    0x8(%ebp),%edi
  801824:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801827:	85 c9                	test   %ecx,%ecx
  801829:	74 36                	je     801861 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80182b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801831:	75 28                	jne    80185b <memset+0x40>
  801833:	f6 c1 03             	test   $0x3,%cl
  801836:	75 23                	jne    80185b <memset+0x40>
		c &= 0xFF;
  801838:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80183c:	89 d3                	mov    %edx,%ebx
  80183e:	c1 e3 08             	shl    $0x8,%ebx
  801841:	89 d6                	mov    %edx,%esi
  801843:	c1 e6 18             	shl    $0x18,%esi
  801846:	89 d0                	mov    %edx,%eax
  801848:	c1 e0 10             	shl    $0x10,%eax
  80184b:	09 f0                	or     %esi,%eax
  80184d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80184f:	89 d8                	mov    %ebx,%eax
  801851:	09 d0                	or     %edx,%eax
  801853:	c1 e9 02             	shr    $0x2,%ecx
  801856:	fc                   	cld    
  801857:	f3 ab                	rep stos %eax,%es:(%edi)
  801859:	eb 06                	jmp    801861 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80185e:	fc                   	cld    
  80185f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801861:	89 f8                	mov    %edi,%eax
  801863:	5b                   	pop    %ebx
  801864:	5e                   	pop    %esi
  801865:	5f                   	pop    %edi
  801866:	5d                   	pop    %ebp
  801867:	c3                   	ret    

00801868 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801868:	55                   	push   %ebp
  801869:	89 e5                	mov    %esp,%ebp
  80186b:	57                   	push   %edi
  80186c:	56                   	push   %esi
  80186d:	8b 45 08             	mov    0x8(%ebp),%eax
  801870:	8b 75 0c             	mov    0xc(%ebp),%esi
  801873:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801876:	39 c6                	cmp    %eax,%esi
  801878:	73 35                	jae    8018af <memmove+0x47>
  80187a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80187d:	39 d0                	cmp    %edx,%eax
  80187f:	73 2e                	jae    8018af <memmove+0x47>
		s += n;
		d += n;
  801881:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801884:	89 d6                	mov    %edx,%esi
  801886:	09 fe                	or     %edi,%esi
  801888:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80188e:	75 13                	jne    8018a3 <memmove+0x3b>
  801890:	f6 c1 03             	test   $0x3,%cl
  801893:	75 0e                	jne    8018a3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801895:	83 ef 04             	sub    $0x4,%edi
  801898:	8d 72 fc             	lea    -0x4(%edx),%esi
  80189b:	c1 e9 02             	shr    $0x2,%ecx
  80189e:	fd                   	std    
  80189f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a1:	eb 09                	jmp    8018ac <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018a3:	83 ef 01             	sub    $0x1,%edi
  8018a6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018a9:	fd                   	std    
  8018aa:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018ac:	fc                   	cld    
  8018ad:	eb 1d                	jmp    8018cc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018af:	89 f2                	mov    %esi,%edx
  8018b1:	09 c2                	or     %eax,%edx
  8018b3:	f6 c2 03             	test   $0x3,%dl
  8018b6:	75 0f                	jne    8018c7 <memmove+0x5f>
  8018b8:	f6 c1 03             	test   $0x3,%cl
  8018bb:	75 0a                	jne    8018c7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018bd:	c1 e9 02             	shr    $0x2,%ecx
  8018c0:	89 c7                	mov    %eax,%edi
  8018c2:	fc                   	cld    
  8018c3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c5:	eb 05                	jmp    8018cc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018c7:	89 c7                	mov    %eax,%edi
  8018c9:	fc                   	cld    
  8018ca:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018cc:	5e                   	pop    %esi
  8018cd:	5f                   	pop    %edi
  8018ce:	5d                   	pop    %ebp
  8018cf:	c3                   	ret    

008018d0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d0:	55                   	push   %ebp
  8018d1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d3:	ff 75 10             	pushl  0x10(%ebp)
  8018d6:	ff 75 0c             	pushl  0xc(%ebp)
  8018d9:	ff 75 08             	pushl  0x8(%ebp)
  8018dc:	e8 87 ff ff ff       	call   801868 <memmove>
}
  8018e1:	c9                   	leave  
  8018e2:	c3                   	ret    

008018e3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e3:	55                   	push   %ebp
  8018e4:	89 e5                	mov    %esp,%ebp
  8018e6:	56                   	push   %esi
  8018e7:	53                   	push   %ebx
  8018e8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018eb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018ee:	89 c6                	mov    %eax,%esi
  8018f0:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f3:	eb 1a                	jmp    80190f <memcmp+0x2c>
		if (*s1 != *s2)
  8018f5:	0f b6 08             	movzbl (%eax),%ecx
  8018f8:	0f b6 1a             	movzbl (%edx),%ebx
  8018fb:	38 d9                	cmp    %bl,%cl
  8018fd:	74 0a                	je     801909 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  8018ff:	0f b6 c1             	movzbl %cl,%eax
  801902:	0f b6 db             	movzbl %bl,%ebx
  801905:	29 d8                	sub    %ebx,%eax
  801907:	eb 0f                	jmp    801918 <memcmp+0x35>
		s1++, s2++;
  801909:	83 c0 01             	add    $0x1,%eax
  80190c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80190f:	39 f0                	cmp    %esi,%eax
  801911:	75 e2                	jne    8018f5 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801913:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801918:	5b                   	pop    %ebx
  801919:	5e                   	pop    %esi
  80191a:	5d                   	pop    %ebp
  80191b:	c3                   	ret    

0080191c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80191c:	55                   	push   %ebp
  80191d:	89 e5                	mov    %esp,%ebp
  80191f:	53                   	push   %ebx
  801920:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801923:	89 c1                	mov    %eax,%ecx
  801925:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801928:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80192c:	eb 0a                	jmp    801938 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80192e:	0f b6 10             	movzbl (%eax),%edx
  801931:	39 da                	cmp    %ebx,%edx
  801933:	74 07                	je     80193c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801935:	83 c0 01             	add    $0x1,%eax
  801938:	39 c8                	cmp    %ecx,%eax
  80193a:	72 f2                	jb     80192e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80193c:	5b                   	pop    %ebx
  80193d:	5d                   	pop    %ebp
  80193e:	c3                   	ret    

0080193f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80193f:	55                   	push   %ebp
  801940:	89 e5                	mov    %esp,%ebp
  801942:	57                   	push   %edi
  801943:	56                   	push   %esi
  801944:	53                   	push   %ebx
  801945:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801948:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80194b:	eb 03                	jmp    801950 <strtol+0x11>
		s++;
  80194d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801950:	0f b6 01             	movzbl (%ecx),%eax
  801953:	3c 20                	cmp    $0x20,%al
  801955:	74 f6                	je     80194d <strtol+0xe>
  801957:	3c 09                	cmp    $0x9,%al
  801959:	74 f2                	je     80194d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80195b:	3c 2b                	cmp    $0x2b,%al
  80195d:	75 0a                	jne    801969 <strtol+0x2a>
		s++;
  80195f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801962:	bf 00 00 00 00       	mov    $0x0,%edi
  801967:	eb 11                	jmp    80197a <strtol+0x3b>
  801969:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80196e:	3c 2d                	cmp    $0x2d,%al
  801970:	75 08                	jne    80197a <strtol+0x3b>
		s++, neg = 1;
  801972:	83 c1 01             	add    $0x1,%ecx
  801975:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801980:	75 15                	jne    801997 <strtol+0x58>
  801982:	80 39 30             	cmpb   $0x30,(%ecx)
  801985:	75 10                	jne    801997 <strtol+0x58>
  801987:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80198b:	75 7c                	jne    801a09 <strtol+0xca>
		s += 2, base = 16;
  80198d:	83 c1 02             	add    $0x2,%ecx
  801990:	bb 10 00 00 00       	mov    $0x10,%ebx
  801995:	eb 16                	jmp    8019ad <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  801997:	85 db                	test   %ebx,%ebx
  801999:	75 12                	jne    8019ad <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80199b:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a0:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a3:	75 08                	jne    8019ad <strtol+0x6e>
		s++, base = 8;
  8019a5:	83 c1 01             	add    $0x1,%ecx
  8019a8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019b5:	0f b6 11             	movzbl (%ecx),%edx
  8019b8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019bb:	89 f3                	mov    %esi,%ebx
  8019bd:	80 fb 09             	cmp    $0x9,%bl
  8019c0:	77 08                	ja     8019ca <strtol+0x8b>
			dig = *s - '0';
  8019c2:	0f be d2             	movsbl %dl,%edx
  8019c5:	83 ea 30             	sub    $0x30,%edx
  8019c8:	eb 22                	jmp    8019ec <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019ca:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019cd:	89 f3                	mov    %esi,%ebx
  8019cf:	80 fb 19             	cmp    $0x19,%bl
  8019d2:	77 08                	ja     8019dc <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019d4:	0f be d2             	movsbl %dl,%edx
  8019d7:	83 ea 57             	sub    $0x57,%edx
  8019da:	eb 10                	jmp    8019ec <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019dc:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019df:	89 f3                	mov    %esi,%ebx
  8019e1:	80 fb 19             	cmp    $0x19,%bl
  8019e4:	77 16                	ja     8019fc <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019e6:	0f be d2             	movsbl %dl,%edx
  8019e9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019ec:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ef:	7d 0b                	jge    8019fc <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019f1:	83 c1 01             	add    $0x1,%ecx
  8019f4:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019f8:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019fa:	eb b9                	jmp    8019b5 <strtol+0x76>

	if (endptr)
  8019fc:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a00:	74 0d                	je     801a0f <strtol+0xd0>
		*endptr = (char *) s;
  801a02:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a05:	89 0e                	mov    %ecx,(%esi)
  801a07:	eb 06                	jmp    801a0f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a09:	85 db                	test   %ebx,%ebx
  801a0b:	74 98                	je     8019a5 <strtol+0x66>
  801a0d:	eb 9e                	jmp    8019ad <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a0f:	89 c2                	mov    %eax,%edx
  801a11:	f7 da                	neg    %edx
  801a13:	85 ff                	test   %edi,%edi
  801a15:	0f 45 c2             	cmovne %edx,%eax
}
  801a18:	5b                   	pop    %ebx
  801a19:	5e                   	pop    %esi
  801a1a:	5f                   	pop    %edi
  801a1b:	5d                   	pop    %ebp
  801a1c:	c3                   	ret    

00801a1d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a1d:	55                   	push   %ebp
  801a1e:	89 e5                	mov    %esp,%ebp
  801a20:	56                   	push   %esi
  801a21:	53                   	push   %ebx
  801a22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a25:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801a28:	83 ec 0c             	sub    $0xc,%esp
  801a2b:	ff 75 0c             	pushl  0xc(%ebp)
  801a2e:	e8 d7 e8 ff ff       	call   80030a <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801a33:	83 c4 10             	add    $0x10,%esp
  801a36:	85 f6                	test   %esi,%esi
  801a38:	74 1c                	je     801a56 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801a3a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a3f:	8b 40 78             	mov    0x78(%eax),%eax
  801a42:	89 06                	mov    %eax,(%esi)
  801a44:	eb 10                	jmp    801a56 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801a46:	83 ec 0c             	sub    $0xc,%esp
  801a49:	68 20 22 80 00       	push   $0x802220
  801a4e:	e8 b4 f6 ff ff       	call   801107 <cprintf>
  801a53:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801a56:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5b:	8b 50 74             	mov    0x74(%eax),%edx
  801a5e:	85 d2                	test   %edx,%edx
  801a60:	74 e4                	je     801a46 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801a62:	85 db                	test   %ebx,%ebx
  801a64:	74 05                	je     801a6b <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801a66:	8b 40 74             	mov    0x74(%eax),%eax
  801a69:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a6b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a70:	8b 40 70             	mov    0x70(%eax),%eax

}
  801a73:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a76:	5b                   	pop    %ebx
  801a77:	5e                   	pop    %esi
  801a78:	5d                   	pop    %ebp
  801a79:	c3                   	ret    

00801a7a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a7a:	55                   	push   %ebp
  801a7b:	89 e5                	mov    %esp,%ebp
  801a7d:	57                   	push   %edi
  801a7e:	56                   	push   %esi
  801a7f:	53                   	push   %ebx
  801a80:	83 ec 0c             	sub    $0xc,%esp
  801a83:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a86:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a89:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801a8c:	85 db                	test   %ebx,%ebx
  801a8e:	75 13                	jne    801aa3 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801a90:	6a 00                	push   $0x0
  801a92:	68 00 00 c0 ee       	push   $0xeec00000
  801a97:	56                   	push   %esi
  801a98:	57                   	push   %edi
  801a99:	e8 49 e8 ff ff       	call   8002e7 <sys_ipc_try_send>
  801a9e:	83 c4 10             	add    $0x10,%esp
  801aa1:	eb 0e                	jmp    801ab1 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801aa3:	ff 75 14             	pushl  0x14(%ebp)
  801aa6:	53                   	push   %ebx
  801aa7:	56                   	push   %esi
  801aa8:	57                   	push   %edi
  801aa9:	e8 39 e8 ff ff       	call   8002e7 <sys_ipc_try_send>
  801aae:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801ab1:	85 c0                	test   %eax,%eax
  801ab3:	75 d7                	jne    801a8c <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801ab5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ab8:	5b                   	pop    %ebx
  801ab9:	5e                   	pop    %esi
  801aba:	5f                   	pop    %edi
  801abb:	5d                   	pop    %ebp
  801abc:	c3                   	ret    

00801abd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801abd:	55                   	push   %ebp
  801abe:	89 e5                	mov    %esp,%ebp
  801ac0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ac8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801acb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad1:	8b 52 50             	mov    0x50(%edx),%edx
  801ad4:	39 ca                	cmp    %ecx,%edx
  801ad6:	75 0d                	jne    801ae5 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ad8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801adb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ae0:	8b 40 48             	mov    0x48(%eax),%eax
  801ae3:	eb 0f                	jmp    801af4 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae5:	83 c0 01             	add    $0x1,%eax
  801ae8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801aed:	75 d9                	jne    801ac8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aef:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af4:	5d                   	pop    %ebp
  801af5:	c3                   	ret    

00801af6 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801af6:	55                   	push   %ebp
  801af7:	89 e5                	mov    %esp,%ebp
  801af9:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801afc:	89 d0                	mov    %edx,%eax
  801afe:	c1 e8 16             	shr    $0x16,%eax
  801b01:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b08:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0d:	f6 c1 01             	test   $0x1,%cl
  801b10:	74 1d                	je     801b2f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b12:	c1 ea 0c             	shr    $0xc,%edx
  801b15:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b1c:	f6 c2 01             	test   $0x1,%dl
  801b1f:	74 0e                	je     801b2f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b21:	c1 ea 0c             	shr    $0xc,%edx
  801b24:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2b:	ef 
  801b2c:	0f b7 c0             	movzwl %ax,%eax
}
  801b2f:	5d                   	pop    %ebp
  801b30:	c3                   	ret    
  801b31:	66 90                	xchg   %ax,%ax
  801b33:	66 90                	xchg   %ax,%ax
  801b35:	66 90                	xchg   %ax,%ax
  801b37:	66 90                	xchg   %ax,%ax
  801b39:	66 90                	xchg   %ax,%ax
  801b3b:	66 90                	xchg   %ax,%ax
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
