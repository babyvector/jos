
obj/user/badsegment:     file format elf32-i386


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
  800049:	e8 c6 00 00 00       	call   800114 <sys_getenvid>
  80004e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800053:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800056:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005b:	a3 04 20 80 00       	mov    %eax,0x802004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800060:	85 db                	test   %ebx,%ebx
  800062:	7e 07                	jle    80006b <libmain+0x2d>
		binaryname = argv[0];
  800064:	8b 06                	mov    (%esi),%eax
  800066:	a3 00 20 80 00       	mov    %eax,0x802000

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
  800087:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80008a:	6a 00                	push   $0x0
  80008c:	e8 42 00 00 00       	call   8000d3 <sys_env_destroy>
}
  800091:	83 c4 10             	add    $0x10,%esp
  800094:	c9                   	leave  
  800095:	c3                   	ret    

00800096 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  800096:	55                   	push   %ebp
  800097:	89 e5                	mov    %esp,%ebp
  800099:	57                   	push   %edi
  80009a:	56                   	push   %esi
  80009b:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80009c:	b8 00 00 00 00       	mov    $0x0,%eax
  8000a1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000a4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000a7:	89 c3                	mov    %eax,%ebx
  8000a9:	89 c7                	mov    %eax,%edi
  8000ab:	89 c6                	mov    %eax,%esi
  8000ad:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000af:	5b                   	pop    %ebx
  8000b0:	5e                   	pop    %esi
  8000b1:	5f                   	pop    %edi
  8000b2:	5d                   	pop    %ebp
  8000b3:	c3                   	ret    

008000b4 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000ba:	ba 00 00 00 00       	mov    $0x0,%edx
  8000bf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000c4:	89 d1                	mov    %edx,%ecx
  8000c6:	89 d3                	mov    %edx,%ebx
  8000c8:	89 d7                	mov    %edx,%edi
  8000ca:	89 d6                	mov    %edx,%esi
  8000cc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000ce:	5b                   	pop    %ebx
  8000cf:	5e                   	pop    %esi
  8000d0:	5f                   	pop    %edi
  8000d1:	5d                   	pop    %ebp
  8000d2:	c3                   	ret    

008000d3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000d3:	55                   	push   %ebp
  8000d4:	89 e5                	mov    %esp,%ebp
  8000d6:	57                   	push   %edi
  8000d7:	56                   	push   %esi
  8000d8:	53                   	push   %ebx
  8000d9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000dc:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000e1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000e6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000e9:	89 cb                	mov    %ecx,%ebx
  8000eb:	89 cf                	mov    %ecx,%edi
  8000ed:	89 ce                	mov    %ecx,%esi
  8000ef:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8000f1:	85 c0                	test   %eax,%eax
  8000f3:	7e 17                	jle    80010c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8000f5:	83 ec 0c             	sub    $0xc,%esp
  8000f8:	50                   	push   %eax
  8000f9:	6a 03                	push   $0x3
  8000fb:	68 8a 0f 80 00       	push   $0x800f8a
  800100:	6a 23                	push   $0x23
  800102:	68 a7 0f 80 00       	push   $0x800fa7
  800107:	e8 f5 01 00 00       	call   800301 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80010c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80010f:	5b                   	pop    %ebx
  800110:	5e                   	pop    %esi
  800111:	5f                   	pop    %edi
  800112:	5d                   	pop    %ebp
  800113:	c3                   	ret    

00800114 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800114:	55                   	push   %ebp
  800115:	89 e5                	mov    %esp,%ebp
  800117:	57                   	push   %edi
  800118:	56                   	push   %esi
  800119:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80011a:	ba 00 00 00 00       	mov    $0x0,%edx
  80011f:	b8 02 00 00 00       	mov    $0x2,%eax
  800124:	89 d1                	mov    %edx,%ecx
  800126:	89 d3                	mov    %edx,%ebx
  800128:	89 d7                	mov    %edx,%edi
  80012a:	89 d6                	mov    %edx,%esi
  80012c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80012e:	5b                   	pop    %ebx
  80012f:	5e                   	pop    %esi
  800130:	5f                   	pop    %edi
  800131:	5d                   	pop    %ebp
  800132:	c3                   	ret    

00800133 <sys_yield>:

void
sys_yield(void)
{
  800133:	55                   	push   %ebp
  800134:	89 e5                	mov    %esp,%ebp
  800136:	57                   	push   %edi
  800137:	56                   	push   %esi
  800138:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800139:	ba 00 00 00 00       	mov    $0x0,%edx
  80013e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800143:	89 d1                	mov    %edx,%ecx
  800145:	89 d3                	mov    %edx,%ebx
  800147:	89 d7                	mov    %edx,%edi
  800149:	89 d6                	mov    %edx,%esi
  80014b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80014d:	5b                   	pop    %ebx
  80014e:	5e                   	pop    %esi
  80014f:	5f                   	pop    %edi
  800150:	5d                   	pop    %ebp
  800151:	c3                   	ret    

00800152 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800152:	55                   	push   %ebp
  800153:	89 e5                	mov    %esp,%ebp
  800155:	57                   	push   %edi
  800156:	56                   	push   %esi
  800157:	53                   	push   %ebx
  800158:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80015b:	be 00 00 00 00       	mov    $0x0,%esi
  800160:	b8 04 00 00 00       	mov    $0x4,%eax
  800165:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800168:	8b 55 08             	mov    0x8(%ebp),%edx
  80016b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80016e:	89 f7                	mov    %esi,%edi
  800170:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800172:	85 c0                	test   %eax,%eax
  800174:	7e 17                	jle    80018d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800176:	83 ec 0c             	sub    $0xc,%esp
  800179:	50                   	push   %eax
  80017a:	6a 04                	push   $0x4
  80017c:	68 8a 0f 80 00       	push   $0x800f8a
  800181:	6a 23                	push   $0x23
  800183:	68 a7 0f 80 00       	push   $0x800fa7
  800188:	e8 74 01 00 00       	call   800301 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80018d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800190:	5b                   	pop    %ebx
  800191:	5e                   	pop    %esi
  800192:	5f                   	pop    %edi
  800193:	5d                   	pop    %ebp
  800194:	c3                   	ret    

00800195 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  800195:	55                   	push   %ebp
  800196:	89 e5                	mov    %esp,%ebp
  800198:	57                   	push   %edi
  800199:	56                   	push   %esi
  80019a:	53                   	push   %ebx
  80019b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80019e:	b8 05 00 00 00       	mov    $0x5,%eax
  8001a3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001a6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001a9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001ac:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001af:	8b 75 18             	mov    0x18(%ebp),%esi
  8001b2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001b4:	85 c0                	test   %eax,%eax
  8001b6:	7e 17                	jle    8001cf <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001b8:	83 ec 0c             	sub    $0xc,%esp
  8001bb:	50                   	push   %eax
  8001bc:	6a 05                	push   $0x5
  8001be:	68 8a 0f 80 00       	push   $0x800f8a
  8001c3:	6a 23                	push   $0x23
  8001c5:	68 a7 0f 80 00       	push   $0x800fa7
  8001ca:	e8 32 01 00 00       	call   800301 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001d2:	5b                   	pop    %ebx
  8001d3:	5e                   	pop    %esi
  8001d4:	5f                   	pop    %edi
  8001d5:	5d                   	pop    %ebp
  8001d6:	c3                   	ret    

008001d7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001d7:	55                   	push   %ebp
  8001d8:	89 e5                	mov    %esp,%ebp
  8001da:	57                   	push   %edi
  8001db:	56                   	push   %esi
  8001dc:	53                   	push   %ebx
  8001dd:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001e0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001e5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001ea:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001ed:	8b 55 08             	mov    0x8(%ebp),%edx
  8001f0:	89 df                	mov    %ebx,%edi
  8001f2:	89 de                	mov    %ebx,%esi
  8001f4:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001f6:	85 c0                	test   %eax,%eax
  8001f8:	7e 17                	jle    800211 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001fa:	83 ec 0c             	sub    $0xc,%esp
  8001fd:	50                   	push   %eax
  8001fe:	6a 06                	push   $0x6
  800200:	68 8a 0f 80 00       	push   $0x800f8a
  800205:	6a 23                	push   $0x23
  800207:	68 a7 0f 80 00       	push   $0x800fa7
  80020c:	e8 f0 00 00 00       	call   800301 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800211:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800214:	5b                   	pop    %ebx
  800215:	5e                   	pop    %esi
  800216:	5f                   	pop    %edi
  800217:	5d                   	pop    %ebp
  800218:	c3                   	ret    

00800219 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800219:	55                   	push   %ebp
  80021a:	89 e5                	mov    %esp,%ebp
  80021c:	57                   	push   %edi
  80021d:	56                   	push   %esi
  80021e:	53                   	push   %ebx
  80021f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800222:	bb 00 00 00 00       	mov    $0x0,%ebx
  800227:	b8 08 00 00 00       	mov    $0x8,%eax
  80022c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80022f:	8b 55 08             	mov    0x8(%ebp),%edx
  800232:	89 df                	mov    %ebx,%edi
  800234:	89 de                	mov    %ebx,%esi
  800236:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800238:	85 c0                	test   %eax,%eax
  80023a:	7e 17                	jle    800253 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80023c:	83 ec 0c             	sub    $0xc,%esp
  80023f:	50                   	push   %eax
  800240:	6a 08                	push   $0x8
  800242:	68 8a 0f 80 00       	push   $0x800f8a
  800247:	6a 23                	push   $0x23
  800249:	68 a7 0f 80 00       	push   $0x800fa7
  80024e:	e8 ae 00 00 00       	call   800301 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800253:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800256:	5b                   	pop    %ebx
  800257:	5e                   	pop    %esi
  800258:	5f                   	pop    %edi
  800259:	5d                   	pop    %ebp
  80025a:	c3                   	ret    

0080025b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80025b:	55                   	push   %ebp
  80025c:	89 e5                	mov    %esp,%ebp
  80025e:	57                   	push   %edi
  80025f:	56                   	push   %esi
  800260:	53                   	push   %ebx
  800261:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800264:	bb 00 00 00 00       	mov    $0x0,%ebx
  800269:	b8 09 00 00 00       	mov    $0x9,%eax
  80026e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800271:	8b 55 08             	mov    0x8(%ebp),%edx
  800274:	89 df                	mov    %ebx,%edi
  800276:	89 de                	mov    %ebx,%esi
  800278:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80027a:	85 c0                	test   %eax,%eax
  80027c:	7e 17                	jle    800295 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80027e:	83 ec 0c             	sub    $0xc,%esp
  800281:	50                   	push   %eax
  800282:	6a 09                	push   $0x9
  800284:	68 8a 0f 80 00       	push   $0x800f8a
  800289:	6a 23                	push   $0x23
  80028b:	68 a7 0f 80 00       	push   $0x800fa7
  800290:	e8 6c 00 00 00       	call   800301 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  800295:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800298:	5b                   	pop    %ebx
  800299:	5e                   	pop    %esi
  80029a:	5f                   	pop    %edi
  80029b:	5d                   	pop    %ebp
  80029c:	c3                   	ret    

0080029d <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  80029d:	55                   	push   %ebp
  80029e:	89 e5                	mov    %esp,%ebp
  8002a0:	57                   	push   %edi
  8002a1:	56                   	push   %esi
  8002a2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002a3:	be 00 00 00 00       	mov    $0x0,%esi
  8002a8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002b3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002b6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002b9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002bb:	5b                   	pop    %ebx
  8002bc:	5e                   	pop    %esi
  8002bd:	5f                   	pop    %edi
  8002be:	5d                   	pop    %ebp
  8002bf:	c3                   	ret    

008002c0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002c0:	55                   	push   %ebp
  8002c1:	89 e5                	mov    %esp,%ebp
  8002c3:	57                   	push   %edi
  8002c4:	56                   	push   %esi
  8002c5:	53                   	push   %ebx
  8002c6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002c9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002ce:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002d3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002d6:	89 cb                	mov    %ecx,%ebx
  8002d8:	89 cf                	mov    %ecx,%edi
  8002da:	89 ce                	mov    %ecx,%esi
  8002dc:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002de:	85 c0                	test   %eax,%eax
  8002e0:	7e 17                	jle    8002f9 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002e2:	83 ec 0c             	sub    $0xc,%esp
  8002e5:	50                   	push   %eax
  8002e6:	6a 0c                	push   $0xc
  8002e8:	68 8a 0f 80 00       	push   $0x800f8a
  8002ed:	6a 23                	push   $0x23
  8002ef:	68 a7 0f 80 00       	push   $0x800fa7
  8002f4:	e8 08 00 00 00       	call   800301 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  8002f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002fc:	5b                   	pop    %ebx
  8002fd:	5e                   	pop    %esi
  8002fe:	5f                   	pop    %edi
  8002ff:	5d                   	pop    %ebp
  800300:	c3                   	ret    

00800301 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800301:	55                   	push   %ebp
  800302:	89 e5                	mov    %esp,%ebp
  800304:	56                   	push   %esi
  800305:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800306:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800309:	8b 35 00 20 80 00    	mov    0x802000,%esi
  80030f:	e8 00 fe ff ff       	call   800114 <sys_getenvid>
  800314:	83 ec 0c             	sub    $0xc,%esp
  800317:	ff 75 0c             	pushl  0xc(%ebp)
  80031a:	ff 75 08             	pushl  0x8(%ebp)
  80031d:	56                   	push   %esi
  80031e:	50                   	push   %eax
  80031f:	68 b8 0f 80 00       	push   $0x800fb8
  800324:	e8 b1 00 00 00       	call   8003da <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800329:	83 c4 18             	add    $0x18,%esp
  80032c:	53                   	push   %ebx
  80032d:	ff 75 10             	pushl  0x10(%ebp)
  800330:	e8 54 00 00 00       	call   800389 <vcprintf>
	cprintf("\n");
  800335:	c7 04 24 dc 0f 80 00 	movl   $0x800fdc,(%esp)
  80033c:	e8 99 00 00 00       	call   8003da <cprintf>
  800341:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800344:	cc                   	int3   
  800345:	eb fd                	jmp    800344 <_panic+0x43>

00800347 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800347:	55                   	push   %ebp
  800348:	89 e5                	mov    %esp,%ebp
  80034a:	53                   	push   %ebx
  80034b:	83 ec 04             	sub    $0x4,%esp
  80034e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800351:	8b 13                	mov    (%ebx),%edx
  800353:	8d 42 01             	lea    0x1(%edx),%eax
  800356:	89 03                	mov    %eax,(%ebx)
  800358:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80035b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80035f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800364:	75 1a                	jne    800380 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800366:	83 ec 08             	sub    $0x8,%esp
  800369:	68 ff 00 00 00       	push   $0xff
  80036e:	8d 43 08             	lea    0x8(%ebx),%eax
  800371:	50                   	push   %eax
  800372:	e8 1f fd ff ff       	call   800096 <sys_cputs>
		b->idx = 0;
  800377:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80037d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800380:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800384:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800387:	c9                   	leave  
  800388:	c3                   	ret    

00800389 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800389:	55                   	push   %ebp
  80038a:	89 e5                	mov    %esp,%ebp
  80038c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  800392:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  800399:	00 00 00 
	b.cnt = 0;
  80039c:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003a3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003a6:	ff 75 0c             	pushl  0xc(%ebp)
  8003a9:	ff 75 08             	pushl  0x8(%ebp)
  8003ac:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003b2:	50                   	push   %eax
  8003b3:	68 47 03 80 00       	push   $0x800347
  8003b8:	e8 54 01 00 00       	call   800511 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003bd:	83 c4 08             	add    $0x8,%esp
  8003c0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003c6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003cc:	50                   	push   %eax
  8003cd:	e8 c4 fc ff ff       	call   800096 <sys_cputs>

	return b.cnt;
}
  8003d2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003d8:	c9                   	leave  
  8003d9:	c3                   	ret    

008003da <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003da:	55                   	push   %ebp
  8003db:	89 e5                	mov    %esp,%ebp
  8003dd:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003e0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003e3:	50                   	push   %eax
  8003e4:	ff 75 08             	pushl  0x8(%ebp)
  8003e7:	e8 9d ff ff ff       	call   800389 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003ec:	c9                   	leave  
  8003ed:	c3                   	ret    

008003ee <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003ee:	55                   	push   %ebp
  8003ef:	89 e5                	mov    %esp,%ebp
  8003f1:	57                   	push   %edi
  8003f2:	56                   	push   %esi
  8003f3:	53                   	push   %ebx
  8003f4:	83 ec 1c             	sub    $0x1c,%esp
  8003f7:	89 c7                	mov    %eax,%edi
  8003f9:	89 d6                	mov    %edx,%esi
  8003fb:	8b 45 08             	mov    0x8(%ebp),%eax
  8003fe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800401:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800404:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800407:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80040a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80040f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800412:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800415:	39 d3                	cmp    %edx,%ebx
  800417:	72 05                	jb     80041e <printnum+0x30>
  800419:	39 45 10             	cmp    %eax,0x10(%ebp)
  80041c:	77 45                	ja     800463 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80041e:	83 ec 0c             	sub    $0xc,%esp
  800421:	ff 75 18             	pushl  0x18(%ebp)
  800424:	8b 45 14             	mov    0x14(%ebp),%eax
  800427:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80042a:	53                   	push   %ebx
  80042b:	ff 75 10             	pushl  0x10(%ebp)
  80042e:	83 ec 08             	sub    $0x8,%esp
  800431:	ff 75 e4             	pushl  -0x1c(%ebp)
  800434:	ff 75 e0             	pushl  -0x20(%ebp)
  800437:	ff 75 dc             	pushl  -0x24(%ebp)
  80043a:	ff 75 d8             	pushl  -0x28(%ebp)
  80043d:	e8 ae 08 00 00       	call   800cf0 <__udivdi3>
  800442:	83 c4 18             	add    $0x18,%esp
  800445:	52                   	push   %edx
  800446:	50                   	push   %eax
  800447:	89 f2                	mov    %esi,%edx
  800449:	89 f8                	mov    %edi,%eax
  80044b:	e8 9e ff ff ff       	call   8003ee <printnum>
  800450:	83 c4 20             	add    $0x20,%esp
  800453:	eb 18                	jmp    80046d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800455:	83 ec 08             	sub    $0x8,%esp
  800458:	56                   	push   %esi
  800459:	ff 75 18             	pushl  0x18(%ebp)
  80045c:	ff d7                	call   *%edi
  80045e:	83 c4 10             	add    $0x10,%esp
  800461:	eb 03                	jmp    800466 <printnum+0x78>
  800463:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800466:	83 eb 01             	sub    $0x1,%ebx
  800469:	85 db                	test   %ebx,%ebx
  80046b:	7f e8                	jg     800455 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80046d:	83 ec 08             	sub    $0x8,%esp
  800470:	56                   	push   %esi
  800471:	83 ec 04             	sub    $0x4,%esp
  800474:	ff 75 e4             	pushl  -0x1c(%ebp)
  800477:	ff 75 e0             	pushl  -0x20(%ebp)
  80047a:	ff 75 dc             	pushl  -0x24(%ebp)
  80047d:	ff 75 d8             	pushl  -0x28(%ebp)
  800480:	e8 9b 09 00 00       	call   800e20 <__umoddi3>
  800485:	83 c4 14             	add    $0x14,%esp
  800488:	0f be 80 de 0f 80 00 	movsbl 0x800fde(%eax),%eax
  80048f:	50                   	push   %eax
  800490:	ff d7                	call   *%edi
}
  800492:	83 c4 10             	add    $0x10,%esp
  800495:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800498:	5b                   	pop    %ebx
  800499:	5e                   	pop    %esi
  80049a:	5f                   	pop    %edi
  80049b:	5d                   	pop    %ebp
  80049c:	c3                   	ret    

0080049d <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  80049d:	55                   	push   %ebp
  80049e:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004a0:	83 fa 01             	cmp    $0x1,%edx
  8004a3:	7e 0e                	jle    8004b3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004a5:	8b 10                	mov    (%eax),%edx
  8004a7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004aa:	89 08                	mov    %ecx,(%eax)
  8004ac:	8b 02                	mov    (%edx),%eax
  8004ae:	8b 52 04             	mov    0x4(%edx),%edx
  8004b1:	eb 22                	jmp    8004d5 <getuint+0x38>
	else if (lflag)
  8004b3:	85 d2                	test   %edx,%edx
  8004b5:	74 10                	je     8004c7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004b7:	8b 10                	mov    (%eax),%edx
  8004b9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004bc:	89 08                	mov    %ecx,(%eax)
  8004be:	8b 02                	mov    (%edx),%eax
  8004c0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004c5:	eb 0e                	jmp    8004d5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 02                	mov    (%edx),%eax
  8004d0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004d5:	5d                   	pop    %ebp
  8004d6:	c3                   	ret    

008004d7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004d7:	55                   	push   %ebp
  8004d8:	89 e5                	mov    %esp,%ebp
  8004da:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004dd:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004e1:	8b 10                	mov    (%eax),%edx
  8004e3:	3b 50 04             	cmp    0x4(%eax),%edx
  8004e6:	73 0a                	jae    8004f2 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004e8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004eb:	89 08                	mov    %ecx,(%eax)
  8004ed:	8b 45 08             	mov    0x8(%ebp),%eax
  8004f0:	88 02                	mov    %al,(%edx)
}
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  8004fa:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 10             	pushl  0x10(%ebp)
  800501:	ff 75 0c             	pushl  0xc(%ebp)
  800504:	ff 75 08             	pushl  0x8(%ebp)
  800507:	e8 05 00 00 00       	call   800511 <vprintfmt>
	va_end(ap);
}
  80050c:	83 c4 10             	add    $0x10,%esp
  80050f:	c9                   	leave  
  800510:	c3                   	ret    

00800511 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800511:	55                   	push   %ebp
  800512:	89 e5                	mov    %esp,%ebp
  800514:	57                   	push   %edi
  800515:	56                   	push   %esi
  800516:	53                   	push   %ebx
  800517:	83 ec 2c             	sub    $0x2c,%esp
  80051a:	8b 75 08             	mov    0x8(%ebp),%esi
  80051d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800520:	8b 7d 10             	mov    0x10(%ebp),%edi
  800523:	eb 12                	jmp    800537 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800525:	85 c0                	test   %eax,%eax
  800527:	0f 84 d3 03 00 00    	je     800900 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80052d:	83 ec 08             	sub    $0x8,%esp
  800530:	53                   	push   %ebx
  800531:	50                   	push   %eax
  800532:	ff d6                	call   *%esi
  800534:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800537:	83 c7 01             	add    $0x1,%edi
  80053a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80053e:	83 f8 25             	cmp    $0x25,%eax
  800541:	75 e2                	jne    800525 <vprintfmt+0x14>
  800543:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800547:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80054e:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800555:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80055c:	ba 00 00 00 00       	mov    $0x0,%edx
  800561:	eb 07                	jmp    80056a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800563:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800566:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80056a:	8d 47 01             	lea    0x1(%edi),%eax
  80056d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800570:	0f b6 07             	movzbl (%edi),%eax
  800573:	0f b6 c8             	movzbl %al,%ecx
  800576:	83 e8 23             	sub    $0x23,%eax
  800579:	3c 55                	cmp    $0x55,%al
  80057b:	0f 87 64 03 00 00    	ja     8008e5 <vprintfmt+0x3d4>
  800581:	0f b6 c0             	movzbl %al,%eax
  800584:	ff 24 85 a0 10 80 00 	jmp    *0x8010a0(,%eax,4)
  80058b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80058e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  800592:	eb d6                	jmp    80056a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800594:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800597:	b8 00 00 00 00       	mov    $0x0,%eax
  80059c:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  80059f:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005a2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005a6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005a9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005ac:	83 fa 09             	cmp    $0x9,%edx
  8005af:	77 39                	ja     8005ea <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005b1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005b4:	eb e9                	jmp    80059f <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005b6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005b9:	8d 48 04             	lea    0x4(%eax),%ecx
  8005bc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005bf:	8b 00                	mov    (%eax),%eax
  8005c1:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005c4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005c7:	eb 27                	jmp    8005f0 <vprintfmt+0xdf>
  8005c9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005cc:	85 c0                	test   %eax,%eax
  8005ce:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005d3:	0f 49 c8             	cmovns %eax,%ecx
  8005d6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005dc:	eb 8c                	jmp    80056a <vprintfmt+0x59>
  8005de:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005e1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005e8:	eb 80                	jmp    80056a <vprintfmt+0x59>
  8005ea:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005ed:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  8005f0:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8005f4:	0f 89 70 ff ff ff    	jns    80056a <vprintfmt+0x59>
				width = precision, precision = -1;
  8005fa:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8005fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800600:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800607:	e9 5e ff ff ff       	jmp    80056a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80060c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80060f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800612:	e9 53 ff ff ff       	jmp    80056a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800617:	8b 45 14             	mov    0x14(%ebp),%eax
  80061a:	8d 50 04             	lea    0x4(%eax),%edx
  80061d:	89 55 14             	mov    %edx,0x14(%ebp)
  800620:	83 ec 08             	sub    $0x8,%esp
  800623:	53                   	push   %ebx
  800624:	ff 30                	pushl  (%eax)
  800626:	ff d6                	call   *%esi
			break;
  800628:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80062b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80062e:	e9 04 ff ff ff       	jmp    800537 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800633:	8b 45 14             	mov    0x14(%ebp),%eax
  800636:	8d 50 04             	lea    0x4(%eax),%edx
  800639:	89 55 14             	mov    %edx,0x14(%ebp)
  80063c:	8b 00                	mov    (%eax),%eax
  80063e:	99                   	cltd   
  80063f:	31 d0                	xor    %edx,%eax
  800641:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800643:	83 f8 08             	cmp    $0x8,%eax
  800646:	7f 0b                	jg     800653 <vprintfmt+0x142>
  800648:	8b 14 85 00 12 80 00 	mov    0x801200(,%eax,4),%edx
  80064f:	85 d2                	test   %edx,%edx
  800651:	75 18                	jne    80066b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800653:	50                   	push   %eax
  800654:	68 f6 0f 80 00       	push   $0x800ff6
  800659:	53                   	push   %ebx
  80065a:	56                   	push   %esi
  80065b:	e8 94 fe ff ff       	call   8004f4 <printfmt>
  800660:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800663:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800666:	e9 cc fe ff ff       	jmp    800537 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80066b:	52                   	push   %edx
  80066c:	68 ff 0f 80 00       	push   $0x800fff
  800671:	53                   	push   %ebx
  800672:	56                   	push   %esi
  800673:	e8 7c fe ff ff       	call   8004f4 <printfmt>
  800678:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80067b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80067e:	e9 b4 fe ff ff       	jmp    800537 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800683:	8b 45 14             	mov    0x14(%ebp),%eax
  800686:	8d 50 04             	lea    0x4(%eax),%edx
  800689:	89 55 14             	mov    %edx,0x14(%ebp)
  80068c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80068e:	85 ff                	test   %edi,%edi
  800690:	b8 ef 0f 80 00       	mov    $0x800fef,%eax
  800695:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  800698:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80069c:	0f 8e 94 00 00 00    	jle    800736 <vprintfmt+0x225>
  8006a2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006a6:	0f 84 98 00 00 00    	je     800744 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ac:	83 ec 08             	sub    $0x8,%esp
  8006af:	ff 75 c8             	pushl  -0x38(%ebp)
  8006b2:	57                   	push   %edi
  8006b3:	e8 d0 02 00 00       	call   800988 <strnlen>
  8006b8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006bb:	29 c1                	sub    %eax,%ecx
  8006bd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006c0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006c3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006c7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006ca:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006cd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006cf:	eb 0f                	jmp    8006e0 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006d1:	83 ec 08             	sub    $0x8,%esp
  8006d4:	53                   	push   %ebx
  8006d5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006d8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006da:	83 ef 01             	sub    $0x1,%edi
  8006dd:	83 c4 10             	add    $0x10,%esp
  8006e0:	85 ff                	test   %edi,%edi
  8006e2:	7f ed                	jg     8006d1 <vprintfmt+0x1c0>
  8006e4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006e7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006ea:	85 c9                	test   %ecx,%ecx
  8006ec:	b8 00 00 00 00       	mov    $0x0,%eax
  8006f1:	0f 49 c1             	cmovns %ecx,%eax
  8006f4:	29 c1                	sub    %eax,%ecx
  8006f6:	89 75 08             	mov    %esi,0x8(%ebp)
  8006f9:	8b 75 c8             	mov    -0x38(%ebp),%esi
  8006fc:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  8006ff:	89 cb                	mov    %ecx,%ebx
  800701:	eb 4d                	jmp    800750 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800703:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800707:	74 1b                	je     800724 <vprintfmt+0x213>
  800709:	0f be c0             	movsbl %al,%eax
  80070c:	83 e8 20             	sub    $0x20,%eax
  80070f:	83 f8 5e             	cmp    $0x5e,%eax
  800712:	76 10                	jbe    800724 <vprintfmt+0x213>
					putch('?', putdat);
  800714:	83 ec 08             	sub    $0x8,%esp
  800717:	ff 75 0c             	pushl  0xc(%ebp)
  80071a:	6a 3f                	push   $0x3f
  80071c:	ff 55 08             	call   *0x8(%ebp)
  80071f:	83 c4 10             	add    $0x10,%esp
  800722:	eb 0d                	jmp    800731 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 0c             	pushl  0xc(%ebp)
  80072a:	52                   	push   %edx
  80072b:	ff 55 08             	call   *0x8(%ebp)
  80072e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800731:	83 eb 01             	sub    $0x1,%ebx
  800734:	eb 1a                	jmp    800750 <vprintfmt+0x23f>
  800736:	89 75 08             	mov    %esi,0x8(%ebp)
  800739:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80073c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80073f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800742:	eb 0c                	jmp    800750 <vprintfmt+0x23f>
  800744:	89 75 08             	mov    %esi,0x8(%ebp)
  800747:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80074a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800750:	83 c7 01             	add    $0x1,%edi
  800753:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800757:	0f be d0             	movsbl %al,%edx
  80075a:	85 d2                	test   %edx,%edx
  80075c:	74 23                	je     800781 <vprintfmt+0x270>
  80075e:	85 f6                	test   %esi,%esi
  800760:	78 a1                	js     800703 <vprintfmt+0x1f2>
  800762:	83 ee 01             	sub    $0x1,%esi
  800765:	79 9c                	jns    800703 <vprintfmt+0x1f2>
  800767:	89 df                	mov    %ebx,%edi
  800769:	8b 75 08             	mov    0x8(%ebp),%esi
  80076c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80076f:	eb 18                	jmp    800789 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800771:	83 ec 08             	sub    $0x8,%esp
  800774:	53                   	push   %ebx
  800775:	6a 20                	push   $0x20
  800777:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800779:	83 ef 01             	sub    $0x1,%edi
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 08                	jmp    800789 <vprintfmt+0x278>
  800781:	89 df                	mov    %ebx,%edi
  800783:	8b 75 08             	mov    0x8(%ebp),%esi
  800786:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800789:	85 ff                	test   %edi,%edi
  80078b:	7f e4                	jg     800771 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80078d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  800790:	e9 a2 fd ff ff       	jmp    800537 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  800795:	83 fa 01             	cmp    $0x1,%edx
  800798:	7e 16                	jle    8007b0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  80079a:	8b 45 14             	mov    0x14(%ebp),%eax
  80079d:	8d 50 08             	lea    0x8(%eax),%edx
  8007a0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007a3:	8b 50 04             	mov    0x4(%eax),%edx
  8007a6:	8b 00                	mov    (%eax),%eax
  8007a8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007ab:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007ae:	eb 32                	jmp    8007e2 <vprintfmt+0x2d1>
	else if (lflag)
  8007b0:	85 d2                	test   %edx,%edx
  8007b2:	74 18                	je     8007cc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007b7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8007bd:	8b 00                	mov    (%eax),%eax
  8007bf:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007c2:	89 c1                	mov    %eax,%ecx
  8007c4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007c7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007ca:	eb 16                	jmp    8007e2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007cc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007cf:	8d 50 04             	lea    0x4(%eax),%edx
  8007d2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007d5:	8b 00                	mov    (%eax),%eax
  8007d7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007da:	89 c1                	mov    %eax,%ecx
  8007dc:	c1 f9 1f             	sar    $0x1f,%ecx
  8007df:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007e2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007e5:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007e8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007eb:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007ee:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  8007f3:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  8007f7:	0f 89 b0 00 00 00    	jns    8008ad <vprintfmt+0x39c>
				putch('-', putdat);
  8007fd:	83 ec 08             	sub    $0x8,%esp
  800800:	53                   	push   %ebx
  800801:	6a 2d                	push   $0x2d
  800803:	ff d6                	call   *%esi
				num = -(long long) num;
  800805:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800808:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80080b:	f7 d8                	neg    %eax
  80080d:	83 d2 00             	adc    $0x0,%edx
  800810:	f7 da                	neg    %edx
  800812:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800815:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800818:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80081b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800820:	e9 88 00 00 00       	jmp    8008ad <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800825:	8d 45 14             	lea    0x14(%ebp),%eax
  800828:	e8 70 fc ff ff       	call   80049d <getuint>
  80082d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800830:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800833:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800838:	eb 73                	jmp    8008ad <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80083a:	8d 45 14             	lea    0x14(%ebp),%eax
  80083d:	e8 5b fc ff ff       	call   80049d <getuint>
  800842:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800845:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800848:	83 ec 08             	sub    $0x8,%esp
  80084b:	53                   	push   %ebx
  80084c:	6a 58                	push   $0x58
  80084e:	ff d6                	call   *%esi
			putch('X', putdat);
  800850:	83 c4 08             	add    $0x8,%esp
  800853:	53                   	push   %ebx
  800854:	6a 58                	push   $0x58
  800856:	ff d6                	call   *%esi
			putch('X', putdat);
  800858:	83 c4 08             	add    $0x8,%esp
  80085b:	53                   	push   %ebx
  80085c:	6a 58                	push   $0x58
  80085e:	ff d6                	call   *%esi
			goto number;
  800860:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800863:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800868:	eb 43                	jmp    8008ad <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80086a:	83 ec 08             	sub    $0x8,%esp
  80086d:	53                   	push   %ebx
  80086e:	6a 30                	push   $0x30
  800870:	ff d6                	call   *%esi
			putch('x', putdat);
  800872:	83 c4 08             	add    $0x8,%esp
  800875:	53                   	push   %ebx
  800876:	6a 78                	push   $0x78
  800878:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80087a:	8b 45 14             	mov    0x14(%ebp),%eax
  80087d:	8d 50 04             	lea    0x4(%eax),%edx
  800880:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800883:	8b 00                	mov    (%eax),%eax
  800885:	ba 00 00 00 00       	mov    $0x0,%edx
  80088a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80088d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  800890:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  800893:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  800898:	eb 13                	jmp    8008ad <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  80089a:	8d 45 14             	lea    0x14(%ebp),%eax
  80089d:	e8 fb fb ff ff       	call   80049d <getuint>
  8008a2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008a5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008a8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008ad:	83 ec 0c             	sub    $0xc,%esp
  8008b0:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008b4:	52                   	push   %edx
  8008b5:	ff 75 e0             	pushl  -0x20(%ebp)
  8008b8:	50                   	push   %eax
  8008b9:	ff 75 dc             	pushl  -0x24(%ebp)
  8008bc:	ff 75 d8             	pushl  -0x28(%ebp)
  8008bf:	89 da                	mov    %ebx,%edx
  8008c1:	89 f0                	mov    %esi,%eax
  8008c3:	e8 26 fb ff ff       	call   8003ee <printnum>
			break;
  8008c8:	83 c4 20             	add    $0x20,%esp
  8008cb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008ce:	e9 64 fc ff ff       	jmp    800537 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008d3:	83 ec 08             	sub    $0x8,%esp
  8008d6:	53                   	push   %ebx
  8008d7:	51                   	push   %ecx
  8008d8:	ff d6                	call   *%esi
			break;
  8008da:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008dd:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008e0:	e9 52 fc ff ff       	jmp    800537 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008e5:	83 ec 08             	sub    $0x8,%esp
  8008e8:	53                   	push   %ebx
  8008e9:	6a 25                	push   $0x25
  8008eb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008ed:	83 c4 10             	add    $0x10,%esp
  8008f0:	eb 03                	jmp    8008f5 <vprintfmt+0x3e4>
  8008f2:	83 ef 01             	sub    $0x1,%edi
  8008f5:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  8008f9:	75 f7                	jne    8008f2 <vprintfmt+0x3e1>
  8008fb:	e9 37 fc ff ff       	jmp    800537 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800900:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800903:	5b                   	pop    %ebx
  800904:	5e                   	pop    %esi
  800905:	5f                   	pop    %edi
  800906:	5d                   	pop    %ebp
  800907:	c3                   	ret    

00800908 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800908:	55                   	push   %ebp
  800909:	89 e5                	mov    %esp,%ebp
  80090b:	83 ec 18             	sub    $0x18,%esp
  80090e:	8b 45 08             	mov    0x8(%ebp),%eax
  800911:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800914:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800917:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80091b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80091e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800925:	85 c0                	test   %eax,%eax
  800927:	74 26                	je     80094f <vsnprintf+0x47>
  800929:	85 d2                	test   %edx,%edx
  80092b:	7e 22                	jle    80094f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80092d:	ff 75 14             	pushl  0x14(%ebp)
  800930:	ff 75 10             	pushl  0x10(%ebp)
  800933:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800936:	50                   	push   %eax
  800937:	68 d7 04 80 00       	push   $0x8004d7
  80093c:	e8 d0 fb ff ff       	call   800511 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800941:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800944:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800947:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80094a:	83 c4 10             	add    $0x10,%esp
  80094d:	eb 05                	jmp    800954 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80094f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800954:	c9                   	leave  
  800955:	c3                   	ret    

00800956 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800956:	55                   	push   %ebp
  800957:	89 e5                	mov    %esp,%ebp
  800959:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80095c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80095f:	50                   	push   %eax
  800960:	ff 75 10             	pushl  0x10(%ebp)
  800963:	ff 75 0c             	pushl  0xc(%ebp)
  800966:	ff 75 08             	pushl  0x8(%ebp)
  800969:	e8 9a ff ff ff       	call   800908 <vsnprintf>
	va_end(ap);

	return rc;
}
  80096e:	c9                   	leave  
  80096f:	c3                   	ret    

00800970 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800970:	55                   	push   %ebp
  800971:	89 e5                	mov    %esp,%ebp
  800973:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800976:	b8 00 00 00 00       	mov    $0x0,%eax
  80097b:	eb 03                	jmp    800980 <strlen+0x10>
		n++;
  80097d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800980:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800984:	75 f7                	jne    80097d <strlen+0xd>
		n++;
	return n;
}
  800986:	5d                   	pop    %ebp
  800987:	c3                   	ret    

00800988 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800988:	55                   	push   %ebp
  800989:	89 e5                	mov    %esp,%ebp
  80098b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80098e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  800991:	ba 00 00 00 00       	mov    $0x0,%edx
  800996:	eb 03                	jmp    80099b <strnlen+0x13>
		n++;
  800998:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  80099b:	39 c2                	cmp    %eax,%edx
  80099d:	74 08                	je     8009a7 <strnlen+0x1f>
  80099f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009a3:	75 f3                	jne    800998 <strnlen+0x10>
  8009a5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009a7:	5d                   	pop    %ebp
  8009a8:	c3                   	ret    

008009a9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009a9:	55                   	push   %ebp
  8009aa:	89 e5                	mov    %esp,%ebp
  8009ac:	53                   	push   %ebx
  8009ad:	8b 45 08             	mov    0x8(%ebp),%eax
  8009b0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009b3:	89 c2                	mov    %eax,%edx
  8009b5:	83 c2 01             	add    $0x1,%edx
  8009b8:	83 c1 01             	add    $0x1,%ecx
  8009bb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009bf:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009c2:	84 db                	test   %bl,%bl
  8009c4:	75 ef                	jne    8009b5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009c6:	5b                   	pop    %ebx
  8009c7:	5d                   	pop    %ebp
  8009c8:	c3                   	ret    

008009c9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009c9:	55                   	push   %ebp
  8009ca:	89 e5                	mov    %esp,%ebp
  8009cc:	53                   	push   %ebx
  8009cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009d0:	53                   	push   %ebx
  8009d1:	e8 9a ff ff ff       	call   800970 <strlen>
  8009d6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009d9:	ff 75 0c             	pushl  0xc(%ebp)
  8009dc:	01 d8                	add    %ebx,%eax
  8009de:	50                   	push   %eax
  8009df:	e8 c5 ff ff ff       	call   8009a9 <strcpy>
	return dst;
}
  8009e4:	89 d8                	mov    %ebx,%eax
  8009e6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009e9:	c9                   	leave  
  8009ea:	c3                   	ret    

008009eb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009eb:	55                   	push   %ebp
  8009ec:	89 e5                	mov    %esp,%ebp
  8009ee:	56                   	push   %esi
  8009ef:	53                   	push   %ebx
  8009f0:	8b 75 08             	mov    0x8(%ebp),%esi
  8009f3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8009f6:	89 f3                	mov    %esi,%ebx
  8009f8:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  8009fb:	89 f2                	mov    %esi,%edx
  8009fd:	eb 0f                	jmp    800a0e <strncpy+0x23>
		*dst++ = *src;
  8009ff:	83 c2 01             	add    $0x1,%edx
  800a02:	0f b6 01             	movzbl (%ecx),%eax
  800a05:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a08:	80 39 01             	cmpb   $0x1,(%ecx)
  800a0b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0e:	39 da                	cmp    %ebx,%edx
  800a10:	75 ed                	jne    8009ff <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a12:	89 f0                	mov    %esi,%eax
  800a14:	5b                   	pop    %ebx
  800a15:	5e                   	pop    %esi
  800a16:	5d                   	pop    %ebp
  800a17:	c3                   	ret    

00800a18 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a18:	55                   	push   %ebp
  800a19:	89 e5                	mov    %esp,%ebp
  800a1b:	56                   	push   %esi
  800a1c:	53                   	push   %ebx
  800a1d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a23:	8b 55 10             	mov    0x10(%ebp),%edx
  800a26:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a28:	85 d2                	test   %edx,%edx
  800a2a:	74 21                	je     800a4d <strlcpy+0x35>
  800a2c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a30:	89 f2                	mov    %esi,%edx
  800a32:	eb 09                	jmp    800a3d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a34:	83 c2 01             	add    $0x1,%edx
  800a37:	83 c1 01             	add    $0x1,%ecx
  800a3a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a3d:	39 c2                	cmp    %eax,%edx
  800a3f:	74 09                	je     800a4a <strlcpy+0x32>
  800a41:	0f b6 19             	movzbl (%ecx),%ebx
  800a44:	84 db                	test   %bl,%bl
  800a46:	75 ec                	jne    800a34 <strlcpy+0x1c>
  800a48:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a4a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a4d:	29 f0                	sub    %esi,%eax
}
  800a4f:	5b                   	pop    %ebx
  800a50:	5e                   	pop    %esi
  800a51:	5d                   	pop    %ebp
  800a52:	c3                   	ret    

00800a53 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a53:	55                   	push   %ebp
  800a54:	89 e5                	mov    %esp,%ebp
  800a56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a59:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a5c:	eb 06                	jmp    800a64 <strcmp+0x11>
		p++, q++;
  800a5e:	83 c1 01             	add    $0x1,%ecx
  800a61:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a64:	0f b6 01             	movzbl (%ecx),%eax
  800a67:	84 c0                	test   %al,%al
  800a69:	74 04                	je     800a6f <strcmp+0x1c>
  800a6b:	3a 02                	cmp    (%edx),%al
  800a6d:	74 ef                	je     800a5e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a6f:	0f b6 c0             	movzbl %al,%eax
  800a72:	0f b6 12             	movzbl (%edx),%edx
  800a75:	29 d0                	sub    %edx,%eax
}
  800a77:	5d                   	pop    %ebp
  800a78:	c3                   	ret    

00800a79 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a79:	55                   	push   %ebp
  800a7a:	89 e5                	mov    %esp,%ebp
  800a7c:	53                   	push   %ebx
  800a7d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a80:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a83:	89 c3                	mov    %eax,%ebx
  800a85:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a88:	eb 06                	jmp    800a90 <strncmp+0x17>
		n--, p++, q++;
  800a8a:	83 c0 01             	add    $0x1,%eax
  800a8d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800a90:	39 d8                	cmp    %ebx,%eax
  800a92:	74 15                	je     800aa9 <strncmp+0x30>
  800a94:	0f b6 08             	movzbl (%eax),%ecx
  800a97:	84 c9                	test   %cl,%cl
  800a99:	74 04                	je     800a9f <strncmp+0x26>
  800a9b:	3a 0a                	cmp    (%edx),%cl
  800a9d:	74 eb                	je     800a8a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800a9f:	0f b6 00             	movzbl (%eax),%eax
  800aa2:	0f b6 12             	movzbl (%edx),%edx
  800aa5:	29 d0                	sub    %edx,%eax
  800aa7:	eb 05                	jmp    800aae <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800aa9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800aae:	5b                   	pop    %ebx
  800aaf:	5d                   	pop    %ebp
  800ab0:	c3                   	ret    

00800ab1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ab1:	55                   	push   %ebp
  800ab2:	89 e5                	mov    %esp,%ebp
  800ab4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ab7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800abb:	eb 07                	jmp    800ac4 <strchr+0x13>
		if (*s == c)
  800abd:	38 ca                	cmp    %cl,%dl
  800abf:	74 0f                	je     800ad0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ac1:	83 c0 01             	add    $0x1,%eax
  800ac4:	0f b6 10             	movzbl (%eax),%edx
  800ac7:	84 d2                	test   %dl,%dl
  800ac9:	75 f2                	jne    800abd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800acb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ad0:	5d                   	pop    %ebp
  800ad1:	c3                   	ret    

00800ad2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ad2:	55                   	push   %ebp
  800ad3:	89 e5                	mov    %esp,%ebp
  800ad5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ad8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800adc:	eb 03                	jmp    800ae1 <strfind+0xf>
  800ade:	83 c0 01             	add    $0x1,%eax
  800ae1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800ae4:	38 ca                	cmp    %cl,%dl
  800ae6:	74 04                	je     800aec <strfind+0x1a>
  800ae8:	84 d2                	test   %dl,%dl
  800aea:	75 f2                	jne    800ade <strfind+0xc>
			break;
	return (char *) s;
}
  800aec:	5d                   	pop    %ebp
  800aed:	c3                   	ret    

00800aee <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800aee:	55                   	push   %ebp
  800aef:	89 e5                	mov    %esp,%ebp
  800af1:	57                   	push   %edi
  800af2:	56                   	push   %esi
  800af3:	53                   	push   %ebx
  800af4:	8b 7d 08             	mov    0x8(%ebp),%edi
  800af7:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800afa:	85 c9                	test   %ecx,%ecx
  800afc:	74 36                	je     800b34 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800afe:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b04:	75 28                	jne    800b2e <memset+0x40>
  800b06:	f6 c1 03             	test   $0x3,%cl
  800b09:	75 23                	jne    800b2e <memset+0x40>
		c &= 0xFF;
  800b0b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b0f:	89 d3                	mov    %edx,%ebx
  800b11:	c1 e3 08             	shl    $0x8,%ebx
  800b14:	89 d6                	mov    %edx,%esi
  800b16:	c1 e6 18             	shl    $0x18,%esi
  800b19:	89 d0                	mov    %edx,%eax
  800b1b:	c1 e0 10             	shl    $0x10,%eax
  800b1e:	09 f0                	or     %esi,%eax
  800b20:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b22:	89 d8                	mov    %ebx,%eax
  800b24:	09 d0                	or     %edx,%eax
  800b26:	c1 e9 02             	shr    $0x2,%ecx
  800b29:	fc                   	cld    
  800b2a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b2c:	eb 06                	jmp    800b34 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b2e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b31:	fc                   	cld    
  800b32:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b34:	89 f8                	mov    %edi,%eax
  800b36:	5b                   	pop    %ebx
  800b37:	5e                   	pop    %esi
  800b38:	5f                   	pop    %edi
  800b39:	5d                   	pop    %ebp
  800b3a:	c3                   	ret    

00800b3b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b3b:	55                   	push   %ebp
  800b3c:	89 e5                	mov    %esp,%ebp
  800b3e:	57                   	push   %edi
  800b3f:	56                   	push   %esi
  800b40:	8b 45 08             	mov    0x8(%ebp),%eax
  800b43:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b46:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b49:	39 c6                	cmp    %eax,%esi
  800b4b:	73 35                	jae    800b82 <memmove+0x47>
  800b4d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b50:	39 d0                	cmp    %edx,%eax
  800b52:	73 2e                	jae    800b82 <memmove+0x47>
		s += n;
		d += n;
  800b54:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b57:	89 d6                	mov    %edx,%esi
  800b59:	09 fe                	or     %edi,%esi
  800b5b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b61:	75 13                	jne    800b76 <memmove+0x3b>
  800b63:	f6 c1 03             	test   $0x3,%cl
  800b66:	75 0e                	jne    800b76 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b68:	83 ef 04             	sub    $0x4,%edi
  800b6b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b6e:	c1 e9 02             	shr    $0x2,%ecx
  800b71:	fd                   	std    
  800b72:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b74:	eb 09                	jmp    800b7f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b76:	83 ef 01             	sub    $0x1,%edi
  800b79:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b7c:	fd                   	std    
  800b7d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b7f:	fc                   	cld    
  800b80:	eb 1d                	jmp    800b9f <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b82:	89 f2                	mov    %esi,%edx
  800b84:	09 c2                	or     %eax,%edx
  800b86:	f6 c2 03             	test   $0x3,%dl
  800b89:	75 0f                	jne    800b9a <memmove+0x5f>
  800b8b:	f6 c1 03             	test   $0x3,%cl
  800b8e:	75 0a                	jne    800b9a <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800b90:	c1 e9 02             	shr    $0x2,%ecx
  800b93:	89 c7                	mov    %eax,%edi
  800b95:	fc                   	cld    
  800b96:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b98:	eb 05                	jmp    800b9f <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800b9a:	89 c7                	mov    %eax,%edi
  800b9c:	fc                   	cld    
  800b9d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800b9f:	5e                   	pop    %esi
  800ba0:	5f                   	pop    %edi
  800ba1:	5d                   	pop    %ebp
  800ba2:	c3                   	ret    

00800ba3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800ba3:	55                   	push   %ebp
  800ba4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800ba6:	ff 75 10             	pushl  0x10(%ebp)
  800ba9:	ff 75 0c             	pushl  0xc(%ebp)
  800bac:	ff 75 08             	pushl  0x8(%ebp)
  800baf:	e8 87 ff ff ff       	call   800b3b <memmove>
}
  800bb4:	c9                   	leave  
  800bb5:	c3                   	ret    

00800bb6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bb6:	55                   	push   %ebp
  800bb7:	89 e5                	mov    %esp,%ebp
  800bb9:	56                   	push   %esi
  800bba:	53                   	push   %ebx
  800bbb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bbe:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bc1:	89 c6                	mov    %eax,%esi
  800bc3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bc6:	eb 1a                	jmp    800be2 <memcmp+0x2c>
		if (*s1 != *s2)
  800bc8:	0f b6 08             	movzbl (%eax),%ecx
  800bcb:	0f b6 1a             	movzbl (%edx),%ebx
  800bce:	38 d9                	cmp    %bl,%cl
  800bd0:	74 0a                	je     800bdc <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800bd2:	0f b6 c1             	movzbl %cl,%eax
  800bd5:	0f b6 db             	movzbl %bl,%ebx
  800bd8:	29 d8                	sub    %ebx,%eax
  800bda:	eb 0f                	jmp    800beb <memcmp+0x35>
		s1++, s2++;
  800bdc:	83 c0 01             	add    $0x1,%eax
  800bdf:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800be2:	39 f0                	cmp    %esi,%eax
  800be4:	75 e2                	jne    800bc8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800be6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800beb:	5b                   	pop    %ebx
  800bec:	5e                   	pop    %esi
  800bed:	5d                   	pop    %ebp
  800bee:	c3                   	ret    

00800bef <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bef:	55                   	push   %ebp
  800bf0:	89 e5                	mov    %esp,%ebp
  800bf2:	53                   	push   %ebx
  800bf3:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800bf6:	89 c1                	mov    %eax,%ecx
  800bf8:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800bfb:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800bff:	eb 0a                	jmp    800c0b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c01:	0f b6 10             	movzbl (%eax),%edx
  800c04:	39 da                	cmp    %ebx,%edx
  800c06:	74 07                	je     800c0f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c08:	83 c0 01             	add    $0x1,%eax
  800c0b:	39 c8                	cmp    %ecx,%eax
  800c0d:	72 f2                	jb     800c01 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c0f:	5b                   	pop    %ebx
  800c10:	5d                   	pop    %ebp
  800c11:	c3                   	ret    

00800c12 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c12:	55                   	push   %ebp
  800c13:	89 e5                	mov    %esp,%ebp
  800c15:	57                   	push   %edi
  800c16:	56                   	push   %esi
  800c17:	53                   	push   %ebx
  800c18:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c1b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c1e:	eb 03                	jmp    800c23 <strtol+0x11>
		s++;
  800c20:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c23:	0f b6 01             	movzbl (%ecx),%eax
  800c26:	3c 20                	cmp    $0x20,%al
  800c28:	74 f6                	je     800c20 <strtol+0xe>
  800c2a:	3c 09                	cmp    $0x9,%al
  800c2c:	74 f2                	je     800c20 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c2e:	3c 2b                	cmp    $0x2b,%al
  800c30:	75 0a                	jne    800c3c <strtol+0x2a>
		s++;
  800c32:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c35:	bf 00 00 00 00       	mov    $0x0,%edi
  800c3a:	eb 11                	jmp    800c4d <strtol+0x3b>
  800c3c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c41:	3c 2d                	cmp    $0x2d,%al
  800c43:	75 08                	jne    800c4d <strtol+0x3b>
		s++, neg = 1;
  800c45:	83 c1 01             	add    $0x1,%ecx
  800c48:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c4d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c53:	75 15                	jne    800c6a <strtol+0x58>
  800c55:	80 39 30             	cmpb   $0x30,(%ecx)
  800c58:	75 10                	jne    800c6a <strtol+0x58>
  800c5a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c5e:	75 7c                	jne    800cdc <strtol+0xca>
		s += 2, base = 16;
  800c60:	83 c1 02             	add    $0x2,%ecx
  800c63:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c68:	eb 16                	jmp    800c80 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c6a:	85 db                	test   %ebx,%ebx
  800c6c:	75 12                	jne    800c80 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c6e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c73:	80 39 30             	cmpb   $0x30,(%ecx)
  800c76:	75 08                	jne    800c80 <strtol+0x6e>
		s++, base = 8;
  800c78:	83 c1 01             	add    $0x1,%ecx
  800c7b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c80:	b8 00 00 00 00       	mov    $0x0,%eax
  800c85:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c88:	0f b6 11             	movzbl (%ecx),%edx
  800c8b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c8e:	89 f3                	mov    %esi,%ebx
  800c90:	80 fb 09             	cmp    $0x9,%bl
  800c93:	77 08                	ja     800c9d <strtol+0x8b>
			dig = *s - '0';
  800c95:	0f be d2             	movsbl %dl,%edx
  800c98:	83 ea 30             	sub    $0x30,%edx
  800c9b:	eb 22                	jmp    800cbf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800c9d:	8d 72 9f             	lea    -0x61(%edx),%esi
  800ca0:	89 f3                	mov    %esi,%ebx
  800ca2:	80 fb 19             	cmp    $0x19,%bl
  800ca5:	77 08                	ja     800caf <strtol+0x9d>
			dig = *s - 'a' + 10;
  800ca7:	0f be d2             	movsbl %dl,%edx
  800caa:	83 ea 57             	sub    $0x57,%edx
  800cad:	eb 10                	jmp    800cbf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800caf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cb2:	89 f3                	mov    %esi,%ebx
  800cb4:	80 fb 19             	cmp    $0x19,%bl
  800cb7:	77 16                	ja     800ccf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cb9:	0f be d2             	movsbl %dl,%edx
  800cbc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800cbf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cc2:	7d 0b                	jge    800ccf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cc4:	83 c1 01             	add    $0x1,%ecx
  800cc7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800ccb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800ccd:	eb b9                	jmp    800c88 <strtol+0x76>

	if (endptr)
  800ccf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800cd3:	74 0d                	je     800ce2 <strtol+0xd0>
		*endptr = (char *) s;
  800cd5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800cd8:	89 0e                	mov    %ecx,(%esi)
  800cda:	eb 06                	jmp    800ce2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cdc:	85 db                	test   %ebx,%ebx
  800cde:	74 98                	je     800c78 <strtol+0x66>
  800ce0:	eb 9e                	jmp    800c80 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800ce2:	89 c2                	mov    %eax,%edx
  800ce4:	f7 da                	neg    %edx
  800ce6:	85 ff                	test   %edi,%edi
  800ce8:	0f 45 c2             	cmovne %edx,%eax
}
  800ceb:	5b                   	pop    %ebx
  800cec:	5e                   	pop    %esi
  800ced:	5f                   	pop    %edi
  800cee:	5d                   	pop    %ebp
  800cef:	c3                   	ret    

00800cf0 <__udivdi3>:
  800cf0:	55                   	push   %ebp
  800cf1:	57                   	push   %edi
  800cf2:	56                   	push   %esi
  800cf3:	53                   	push   %ebx
  800cf4:	83 ec 1c             	sub    $0x1c,%esp
  800cf7:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800cfb:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800cff:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d03:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d07:	85 f6                	test   %esi,%esi
  800d09:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d0d:	89 ca                	mov    %ecx,%edx
  800d0f:	89 f8                	mov    %edi,%eax
  800d11:	75 3d                	jne    800d50 <__udivdi3+0x60>
  800d13:	39 cf                	cmp    %ecx,%edi
  800d15:	0f 87 c5 00 00 00    	ja     800de0 <__udivdi3+0xf0>
  800d1b:	85 ff                	test   %edi,%edi
  800d1d:	89 fd                	mov    %edi,%ebp
  800d1f:	75 0b                	jne    800d2c <__udivdi3+0x3c>
  800d21:	b8 01 00 00 00       	mov    $0x1,%eax
  800d26:	31 d2                	xor    %edx,%edx
  800d28:	f7 f7                	div    %edi
  800d2a:	89 c5                	mov    %eax,%ebp
  800d2c:	89 c8                	mov    %ecx,%eax
  800d2e:	31 d2                	xor    %edx,%edx
  800d30:	f7 f5                	div    %ebp
  800d32:	89 c1                	mov    %eax,%ecx
  800d34:	89 d8                	mov    %ebx,%eax
  800d36:	89 cf                	mov    %ecx,%edi
  800d38:	f7 f5                	div    %ebp
  800d3a:	89 c3                	mov    %eax,%ebx
  800d3c:	89 d8                	mov    %ebx,%eax
  800d3e:	89 fa                	mov    %edi,%edx
  800d40:	83 c4 1c             	add    $0x1c,%esp
  800d43:	5b                   	pop    %ebx
  800d44:	5e                   	pop    %esi
  800d45:	5f                   	pop    %edi
  800d46:	5d                   	pop    %ebp
  800d47:	c3                   	ret    
  800d48:	90                   	nop
  800d49:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d50:	39 ce                	cmp    %ecx,%esi
  800d52:	77 74                	ja     800dc8 <__udivdi3+0xd8>
  800d54:	0f bd fe             	bsr    %esi,%edi
  800d57:	83 f7 1f             	xor    $0x1f,%edi
  800d5a:	0f 84 98 00 00 00    	je     800df8 <__udivdi3+0x108>
  800d60:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d65:	89 f9                	mov    %edi,%ecx
  800d67:	89 c5                	mov    %eax,%ebp
  800d69:	29 fb                	sub    %edi,%ebx
  800d6b:	d3 e6                	shl    %cl,%esi
  800d6d:	89 d9                	mov    %ebx,%ecx
  800d6f:	d3 ed                	shr    %cl,%ebp
  800d71:	89 f9                	mov    %edi,%ecx
  800d73:	d3 e0                	shl    %cl,%eax
  800d75:	09 ee                	or     %ebp,%esi
  800d77:	89 d9                	mov    %ebx,%ecx
  800d79:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d7d:	89 d5                	mov    %edx,%ebp
  800d7f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d83:	d3 ed                	shr    %cl,%ebp
  800d85:	89 f9                	mov    %edi,%ecx
  800d87:	d3 e2                	shl    %cl,%edx
  800d89:	89 d9                	mov    %ebx,%ecx
  800d8b:	d3 e8                	shr    %cl,%eax
  800d8d:	09 c2                	or     %eax,%edx
  800d8f:	89 d0                	mov    %edx,%eax
  800d91:	89 ea                	mov    %ebp,%edx
  800d93:	f7 f6                	div    %esi
  800d95:	89 d5                	mov    %edx,%ebp
  800d97:	89 c3                	mov    %eax,%ebx
  800d99:	f7 64 24 0c          	mull   0xc(%esp)
  800d9d:	39 d5                	cmp    %edx,%ebp
  800d9f:	72 10                	jb     800db1 <__udivdi3+0xc1>
  800da1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800da5:	89 f9                	mov    %edi,%ecx
  800da7:	d3 e6                	shl    %cl,%esi
  800da9:	39 c6                	cmp    %eax,%esi
  800dab:	73 07                	jae    800db4 <__udivdi3+0xc4>
  800dad:	39 d5                	cmp    %edx,%ebp
  800daf:	75 03                	jne    800db4 <__udivdi3+0xc4>
  800db1:	83 eb 01             	sub    $0x1,%ebx
  800db4:	31 ff                	xor    %edi,%edi
  800db6:	89 d8                	mov    %ebx,%eax
  800db8:	89 fa                	mov    %edi,%edx
  800dba:	83 c4 1c             	add    $0x1c,%esp
  800dbd:	5b                   	pop    %ebx
  800dbe:	5e                   	pop    %esi
  800dbf:	5f                   	pop    %edi
  800dc0:	5d                   	pop    %ebp
  800dc1:	c3                   	ret    
  800dc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dc8:	31 ff                	xor    %edi,%edi
  800dca:	31 db                	xor    %ebx,%ebx
  800dcc:	89 d8                	mov    %ebx,%eax
  800dce:	89 fa                	mov    %edi,%edx
  800dd0:	83 c4 1c             	add    $0x1c,%esp
  800dd3:	5b                   	pop    %ebx
  800dd4:	5e                   	pop    %esi
  800dd5:	5f                   	pop    %edi
  800dd6:	5d                   	pop    %ebp
  800dd7:	c3                   	ret    
  800dd8:	90                   	nop
  800dd9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800de0:	89 d8                	mov    %ebx,%eax
  800de2:	f7 f7                	div    %edi
  800de4:	31 ff                	xor    %edi,%edi
  800de6:	89 c3                	mov    %eax,%ebx
  800de8:	89 d8                	mov    %ebx,%eax
  800dea:	89 fa                	mov    %edi,%edx
  800dec:	83 c4 1c             	add    $0x1c,%esp
  800def:	5b                   	pop    %ebx
  800df0:	5e                   	pop    %esi
  800df1:	5f                   	pop    %edi
  800df2:	5d                   	pop    %ebp
  800df3:	c3                   	ret    
  800df4:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800df8:	39 ce                	cmp    %ecx,%esi
  800dfa:	72 0c                	jb     800e08 <__udivdi3+0x118>
  800dfc:	31 db                	xor    %ebx,%ebx
  800dfe:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e02:	0f 87 34 ff ff ff    	ja     800d3c <__udivdi3+0x4c>
  800e08:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e0d:	e9 2a ff ff ff       	jmp    800d3c <__udivdi3+0x4c>
  800e12:	66 90                	xchg   %ax,%ax
  800e14:	66 90                	xchg   %ax,%ax
  800e16:	66 90                	xchg   %ax,%ax
  800e18:	66 90                	xchg   %ax,%ax
  800e1a:	66 90                	xchg   %ax,%ax
  800e1c:	66 90                	xchg   %ax,%ax
  800e1e:	66 90                	xchg   %ax,%ax

00800e20 <__umoddi3>:
  800e20:	55                   	push   %ebp
  800e21:	57                   	push   %edi
  800e22:	56                   	push   %esi
  800e23:	53                   	push   %ebx
  800e24:	83 ec 1c             	sub    $0x1c,%esp
  800e27:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e2b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e2f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e33:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e37:	85 d2                	test   %edx,%edx
  800e39:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e3d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e41:	89 f3                	mov    %esi,%ebx
  800e43:	89 3c 24             	mov    %edi,(%esp)
  800e46:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e4a:	75 1c                	jne    800e68 <__umoddi3+0x48>
  800e4c:	39 f7                	cmp    %esi,%edi
  800e4e:	76 50                	jbe    800ea0 <__umoddi3+0x80>
  800e50:	89 c8                	mov    %ecx,%eax
  800e52:	89 f2                	mov    %esi,%edx
  800e54:	f7 f7                	div    %edi
  800e56:	89 d0                	mov    %edx,%eax
  800e58:	31 d2                	xor    %edx,%edx
  800e5a:	83 c4 1c             	add    $0x1c,%esp
  800e5d:	5b                   	pop    %ebx
  800e5e:	5e                   	pop    %esi
  800e5f:	5f                   	pop    %edi
  800e60:	5d                   	pop    %ebp
  800e61:	c3                   	ret    
  800e62:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e68:	39 f2                	cmp    %esi,%edx
  800e6a:	89 d0                	mov    %edx,%eax
  800e6c:	77 52                	ja     800ec0 <__umoddi3+0xa0>
  800e6e:	0f bd ea             	bsr    %edx,%ebp
  800e71:	83 f5 1f             	xor    $0x1f,%ebp
  800e74:	75 5a                	jne    800ed0 <__umoddi3+0xb0>
  800e76:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e7a:	0f 82 e0 00 00 00    	jb     800f60 <__umoddi3+0x140>
  800e80:	39 0c 24             	cmp    %ecx,(%esp)
  800e83:	0f 86 d7 00 00 00    	jbe    800f60 <__umoddi3+0x140>
  800e89:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e8d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800e91:	83 c4 1c             	add    $0x1c,%esp
  800e94:	5b                   	pop    %ebx
  800e95:	5e                   	pop    %esi
  800e96:	5f                   	pop    %edi
  800e97:	5d                   	pop    %ebp
  800e98:	c3                   	ret    
  800e99:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800ea0:	85 ff                	test   %edi,%edi
  800ea2:	89 fd                	mov    %edi,%ebp
  800ea4:	75 0b                	jne    800eb1 <__umoddi3+0x91>
  800ea6:	b8 01 00 00 00       	mov    $0x1,%eax
  800eab:	31 d2                	xor    %edx,%edx
  800ead:	f7 f7                	div    %edi
  800eaf:	89 c5                	mov    %eax,%ebp
  800eb1:	89 f0                	mov    %esi,%eax
  800eb3:	31 d2                	xor    %edx,%edx
  800eb5:	f7 f5                	div    %ebp
  800eb7:	89 c8                	mov    %ecx,%eax
  800eb9:	f7 f5                	div    %ebp
  800ebb:	89 d0                	mov    %edx,%eax
  800ebd:	eb 99                	jmp    800e58 <__umoddi3+0x38>
  800ebf:	90                   	nop
  800ec0:	89 c8                	mov    %ecx,%eax
  800ec2:	89 f2                	mov    %esi,%edx
  800ec4:	83 c4 1c             	add    $0x1c,%esp
  800ec7:	5b                   	pop    %ebx
  800ec8:	5e                   	pop    %esi
  800ec9:	5f                   	pop    %edi
  800eca:	5d                   	pop    %ebp
  800ecb:	c3                   	ret    
  800ecc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ed0:	8b 34 24             	mov    (%esp),%esi
  800ed3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ed8:	89 e9                	mov    %ebp,%ecx
  800eda:	29 ef                	sub    %ebp,%edi
  800edc:	d3 e0                	shl    %cl,%eax
  800ede:	89 f9                	mov    %edi,%ecx
  800ee0:	89 f2                	mov    %esi,%edx
  800ee2:	d3 ea                	shr    %cl,%edx
  800ee4:	89 e9                	mov    %ebp,%ecx
  800ee6:	09 c2                	or     %eax,%edx
  800ee8:	89 d8                	mov    %ebx,%eax
  800eea:	89 14 24             	mov    %edx,(%esp)
  800eed:	89 f2                	mov    %esi,%edx
  800eef:	d3 e2                	shl    %cl,%edx
  800ef1:	89 f9                	mov    %edi,%ecx
  800ef3:	89 54 24 04          	mov    %edx,0x4(%esp)
  800ef7:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800efb:	d3 e8                	shr    %cl,%eax
  800efd:	89 e9                	mov    %ebp,%ecx
  800eff:	89 c6                	mov    %eax,%esi
  800f01:	d3 e3                	shl    %cl,%ebx
  800f03:	89 f9                	mov    %edi,%ecx
  800f05:	89 d0                	mov    %edx,%eax
  800f07:	d3 e8                	shr    %cl,%eax
  800f09:	89 e9                	mov    %ebp,%ecx
  800f0b:	09 d8                	or     %ebx,%eax
  800f0d:	89 d3                	mov    %edx,%ebx
  800f0f:	89 f2                	mov    %esi,%edx
  800f11:	f7 34 24             	divl   (%esp)
  800f14:	89 d6                	mov    %edx,%esi
  800f16:	d3 e3                	shl    %cl,%ebx
  800f18:	f7 64 24 04          	mull   0x4(%esp)
  800f1c:	39 d6                	cmp    %edx,%esi
  800f1e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f22:	89 d1                	mov    %edx,%ecx
  800f24:	89 c3                	mov    %eax,%ebx
  800f26:	72 08                	jb     800f30 <__umoddi3+0x110>
  800f28:	75 11                	jne    800f3b <__umoddi3+0x11b>
  800f2a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f2e:	73 0b                	jae    800f3b <__umoddi3+0x11b>
  800f30:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f34:	1b 14 24             	sbb    (%esp),%edx
  800f37:	89 d1                	mov    %edx,%ecx
  800f39:	89 c3                	mov    %eax,%ebx
  800f3b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f3f:	29 da                	sub    %ebx,%edx
  800f41:	19 ce                	sbb    %ecx,%esi
  800f43:	89 f9                	mov    %edi,%ecx
  800f45:	89 f0                	mov    %esi,%eax
  800f47:	d3 e0                	shl    %cl,%eax
  800f49:	89 e9                	mov    %ebp,%ecx
  800f4b:	d3 ea                	shr    %cl,%edx
  800f4d:	89 e9                	mov    %ebp,%ecx
  800f4f:	d3 ee                	shr    %cl,%esi
  800f51:	09 d0                	or     %edx,%eax
  800f53:	89 f2                	mov    %esi,%edx
  800f55:	83 c4 1c             	add    $0x1c,%esp
  800f58:	5b                   	pop    %ebx
  800f59:	5e                   	pop    %esi
  800f5a:	5f                   	pop    %edi
  800f5b:	5d                   	pop    %ebp
  800f5c:	c3                   	ret    
  800f5d:	8d 76 00             	lea    0x0(%esi),%esi
  800f60:	29 f9                	sub    %edi,%ecx
  800f62:	19 d6                	sbb    %edx,%esi
  800f64:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f68:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f6c:	e9 18 ff ff ff       	jmp    800e89 <__umoddi3+0x69>
