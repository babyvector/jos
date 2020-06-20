
obj/user/faultwrite.debug:     file format elf32-i386


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
  80002c:	e8 11 00 00 00       	call   800042 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
	*(unsigned*)0 = 0;
  800036:	c7 05 00 00 00 00 00 	movl   $0x0,0x0
  80003d:	00 00 00 
}
  800040:	5d                   	pop    %ebp
  800041:	c3                   	ret    

00800042 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800042:	55                   	push   %ebp
  800043:	89 e5                	mov    %esp,%ebp
  800045:	56                   	push   %esi
  800046:	53                   	push   %ebx
  800047:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004a:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  80004d:	e8 ce 00 00 00       	call   800120 <sys_getenvid>
  800052:	25 ff 03 00 00       	and    $0x3ff,%eax
  800057:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005a:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80005f:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800064:	85 db                	test   %ebx,%ebx
  800066:	7e 07                	jle    80006f <libmain+0x2d>
		binaryname = argv[0];
  800068:	8b 06                	mov    (%esi),%eax
  80006a:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  80006f:	83 ec 08             	sub    $0x8,%esp
  800072:	56                   	push   %esi
  800073:	53                   	push   %ebx
  800074:	e8 ba ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800079:	e8 0a 00 00 00       	call   800088 <exit>
}
  80007e:	83 c4 10             	add    $0x10,%esp
  800081:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800084:	5b                   	pop    %ebx
  800085:	5e                   	pop    %esi
  800086:	5d                   	pop    %ebp
  800087:	c3                   	ret    

00800088 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800088:	55                   	push   %ebp
  800089:	89 e5                	mov    %esp,%ebp
  80008b:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80008e:	e8 87 04 00 00       	call   80051a <close_all>
	sys_env_destroy(0);
  800093:	83 ec 0c             	sub    $0xc,%esp
  800096:	6a 00                	push   $0x0
  800098:	e8 42 00 00 00       	call   8000df <sys_env_destroy>
}
  80009d:	83 c4 10             	add    $0x10,%esp
  8000a0:	c9                   	leave  
  8000a1:	c3                   	ret    

008000a2 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a2:	55                   	push   %ebp
  8000a3:	89 e5                	mov    %esp,%ebp
  8000a5:	57                   	push   %edi
  8000a6:	56                   	push   %esi
  8000a7:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000a8:	b8 00 00 00 00       	mov    $0x0,%eax
  8000ad:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b0:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b3:	89 c3                	mov    %eax,%ebx
  8000b5:	89 c7                	mov    %eax,%edi
  8000b7:	89 c6                	mov    %eax,%esi
  8000b9:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bb:	5b                   	pop    %ebx
  8000bc:	5e                   	pop    %esi
  8000bd:	5f                   	pop    %edi
  8000be:	5d                   	pop    %ebp
  8000bf:	c3                   	ret    

008000c0 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c0:	55                   	push   %ebp
  8000c1:	89 e5                	mov    %esp,%ebp
  8000c3:	57                   	push   %edi
  8000c4:	56                   	push   %esi
  8000c5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000c6:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cb:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d0:	89 d1                	mov    %edx,%ecx
  8000d2:	89 d3                	mov    %edx,%ebx
  8000d4:	89 d7                	mov    %edx,%edi
  8000d6:	89 d6                	mov    %edx,%esi
  8000d8:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000da:	5b                   	pop    %ebx
  8000db:	5e                   	pop    %esi
  8000dc:	5f                   	pop    %edi
  8000dd:	5d                   	pop    %ebp
  8000de:	c3                   	ret    

008000df <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000df:	55                   	push   %ebp
  8000e0:	89 e5                	mov    %esp,%ebp
  8000e2:	57                   	push   %edi
  8000e3:	56                   	push   %esi
  8000e4:	53                   	push   %ebx
  8000e5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000e8:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000ed:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f2:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f5:	89 cb                	mov    %ecx,%ebx
  8000f7:	89 cf                	mov    %ecx,%edi
  8000f9:	89 ce                	mov    %ecx,%esi
  8000fb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8000fd:	85 c0                	test   %eax,%eax
  8000ff:	7e 17                	jle    800118 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800101:	83 ec 0c             	sub    $0xc,%esp
  800104:	50                   	push   %eax
  800105:	6a 03                	push   $0x3
  800107:	68 ea 1d 80 00       	push   $0x801dea
  80010c:	6a 23                	push   $0x23
  80010e:	68 07 1e 80 00       	push   $0x801e07
  800113:	e8 1a 0f 00 00       	call   801032 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800118:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011b:	5b                   	pop    %ebx
  80011c:	5e                   	pop    %esi
  80011d:	5f                   	pop    %edi
  80011e:	5d                   	pop    %ebp
  80011f:	c3                   	ret    

00800120 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800120:	55                   	push   %ebp
  800121:	89 e5                	mov    %esp,%ebp
  800123:	57                   	push   %edi
  800124:	56                   	push   %esi
  800125:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800126:	ba 00 00 00 00       	mov    $0x0,%edx
  80012b:	b8 02 00 00 00       	mov    $0x2,%eax
  800130:	89 d1                	mov    %edx,%ecx
  800132:	89 d3                	mov    %edx,%ebx
  800134:	89 d7                	mov    %edx,%edi
  800136:	89 d6                	mov    %edx,%esi
  800138:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013a:	5b                   	pop    %ebx
  80013b:	5e                   	pop    %esi
  80013c:	5f                   	pop    %edi
  80013d:	5d                   	pop    %ebp
  80013e:	c3                   	ret    

0080013f <sys_yield>:

void
sys_yield(void)
{
  80013f:	55                   	push   %ebp
  800140:	89 e5                	mov    %esp,%ebp
  800142:	57                   	push   %edi
  800143:	56                   	push   %esi
  800144:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800145:	ba 00 00 00 00       	mov    $0x0,%edx
  80014a:	b8 0b 00 00 00       	mov    $0xb,%eax
  80014f:	89 d1                	mov    %edx,%ecx
  800151:	89 d3                	mov    %edx,%ebx
  800153:	89 d7                	mov    %edx,%edi
  800155:	89 d6                	mov    %edx,%esi
  800157:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800159:	5b                   	pop    %ebx
  80015a:	5e                   	pop    %esi
  80015b:	5f                   	pop    %edi
  80015c:	5d                   	pop    %ebp
  80015d:	c3                   	ret    

0080015e <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80015e:	55                   	push   %ebp
  80015f:	89 e5                	mov    %esp,%ebp
  800161:	57                   	push   %edi
  800162:	56                   	push   %esi
  800163:	53                   	push   %ebx
  800164:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800167:	be 00 00 00 00       	mov    $0x0,%esi
  80016c:	b8 04 00 00 00       	mov    $0x4,%eax
  800171:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800174:	8b 55 08             	mov    0x8(%ebp),%edx
  800177:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017a:	89 f7                	mov    %esi,%edi
  80017c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80017e:	85 c0                	test   %eax,%eax
  800180:	7e 17                	jle    800199 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800182:	83 ec 0c             	sub    $0xc,%esp
  800185:	50                   	push   %eax
  800186:	6a 04                	push   $0x4
  800188:	68 ea 1d 80 00       	push   $0x801dea
  80018d:	6a 23                	push   $0x23
  80018f:	68 07 1e 80 00       	push   $0x801e07
  800194:	e8 99 0e 00 00       	call   801032 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  800199:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80019c:	5b                   	pop    %ebx
  80019d:	5e                   	pop    %esi
  80019e:	5f                   	pop    %edi
  80019f:	5d                   	pop    %ebp
  8001a0:	c3                   	ret    

008001a1 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a1:	55                   	push   %ebp
  8001a2:	89 e5                	mov    %esp,%ebp
  8001a4:	57                   	push   %edi
  8001a5:	56                   	push   %esi
  8001a6:	53                   	push   %ebx
  8001a7:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001aa:	b8 05 00 00 00       	mov    $0x5,%eax
  8001af:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b2:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b5:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001b8:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bb:	8b 75 18             	mov    0x18(%ebp),%esi
  8001be:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8001c0:	85 c0                	test   %eax,%eax
  8001c2:	7e 17                	jle    8001db <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c4:	83 ec 0c             	sub    $0xc,%esp
  8001c7:	50                   	push   %eax
  8001c8:	6a 05                	push   $0x5
  8001ca:	68 ea 1d 80 00       	push   $0x801dea
  8001cf:	6a 23                	push   $0x23
  8001d1:	68 07 1e 80 00       	push   $0x801e07
  8001d6:	e8 57 0e 00 00       	call   801032 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001db:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001de:	5b                   	pop    %ebx
  8001df:	5e                   	pop    %esi
  8001e0:	5f                   	pop    %edi
  8001e1:	5d                   	pop    %ebp
  8001e2:	c3                   	ret    

008001e3 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e3:	55                   	push   %ebp
  8001e4:	89 e5                	mov    %esp,%ebp
  8001e6:	57                   	push   %edi
  8001e7:	56                   	push   %esi
  8001e8:	53                   	push   %ebx
  8001e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001ec:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f1:	b8 06 00 00 00       	mov    $0x6,%eax
  8001f6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001f9:	8b 55 08             	mov    0x8(%ebp),%edx
  8001fc:	89 df                	mov    %ebx,%edi
  8001fe:	89 de                	mov    %ebx,%esi
  800200:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800202:	85 c0                	test   %eax,%eax
  800204:	7e 17                	jle    80021d <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800206:	83 ec 0c             	sub    $0xc,%esp
  800209:	50                   	push   %eax
  80020a:	6a 06                	push   $0x6
  80020c:	68 ea 1d 80 00       	push   $0x801dea
  800211:	6a 23                	push   $0x23
  800213:	68 07 1e 80 00       	push   $0x801e07
  800218:	e8 15 0e 00 00       	call   801032 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  80021d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800220:	5b                   	pop    %ebx
  800221:	5e                   	pop    %esi
  800222:	5f                   	pop    %edi
  800223:	5d                   	pop    %ebp
  800224:	c3                   	ret    

00800225 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800225:	55                   	push   %ebp
  800226:	89 e5                	mov    %esp,%ebp
  800228:	57                   	push   %edi
  800229:	56                   	push   %esi
  80022a:	53                   	push   %ebx
  80022b:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80022e:	bb 00 00 00 00       	mov    $0x0,%ebx
  800233:	b8 08 00 00 00       	mov    $0x8,%eax
  800238:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023b:	8b 55 08             	mov    0x8(%ebp),%edx
  80023e:	89 df                	mov    %ebx,%edi
  800240:	89 de                	mov    %ebx,%esi
  800242:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800244:	85 c0                	test   %eax,%eax
  800246:	7e 17                	jle    80025f <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800248:	83 ec 0c             	sub    $0xc,%esp
  80024b:	50                   	push   %eax
  80024c:	6a 08                	push   $0x8
  80024e:	68 ea 1d 80 00       	push   $0x801dea
  800253:	6a 23                	push   $0x23
  800255:	68 07 1e 80 00       	push   $0x801e07
  80025a:	e8 d3 0d 00 00       	call   801032 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80025f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800262:	5b                   	pop    %ebx
  800263:	5e                   	pop    %esi
  800264:	5f                   	pop    %edi
  800265:	5d                   	pop    %ebp
  800266:	c3                   	ret    

00800267 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800267:	55                   	push   %ebp
  800268:	89 e5                	mov    %esp,%ebp
  80026a:	57                   	push   %edi
  80026b:	56                   	push   %esi
  80026c:	53                   	push   %ebx
  80026d:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800270:	bb 00 00 00 00       	mov    $0x0,%ebx
  800275:	b8 09 00 00 00       	mov    $0x9,%eax
  80027a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80027d:	8b 55 08             	mov    0x8(%ebp),%edx
  800280:	89 df                	mov    %ebx,%edi
  800282:	89 de                	mov    %ebx,%esi
  800284:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800286:	85 c0                	test   %eax,%eax
  800288:	7e 17                	jle    8002a1 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028a:	83 ec 0c             	sub    $0xc,%esp
  80028d:	50                   	push   %eax
  80028e:	6a 09                	push   $0x9
  800290:	68 ea 1d 80 00       	push   $0x801dea
  800295:	6a 23                	push   $0x23
  800297:	68 07 1e 80 00       	push   $0x801e07
  80029c:	e8 91 0d 00 00       	call   801032 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a1:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a4:	5b                   	pop    %ebx
  8002a5:	5e                   	pop    %esi
  8002a6:	5f                   	pop    %edi
  8002a7:	5d                   	pop    %ebp
  8002a8:	c3                   	ret    

008002a9 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002a9:	55                   	push   %ebp
  8002aa:	89 e5                	mov    %esp,%ebp
  8002ac:	57                   	push   %edi
  8002ad:	56                   	push   %esi
  8002ae:	53                   	push   %ebx
  8002af:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002b2:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002b7:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002bc:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002bf:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c2:	89 df                	mov    %ebx,%edi
  8002c4:	89 de                	mov    %ebx,%esi
  8002c6:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8002c8:	85 c0                	test   %eax,%eax
  8002ca:	7e 17                	jle    8002e3 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002cc:	83 ec 0c             	sub    $0xc,%esp
  8002cf:	50                   	push   %eax
  8002d0:	6a 0a                	push   $0xa
  8002d2:	68 ea 1d 80 00       	push   $0x801dea
  8002d7:	6a 23                	push   $0x23
  8002d9:	68 07 1e 80 00       	push   $0x801e07
  8002de:	e8 4f 0d 00 00       	call   801032 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e3:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002e6:	5b                   	pop    %ebx
  8002e7:	5e                   	pop    %esi
  8002e8:	5f                   	pop    %edi
  8002e9:	5d                   	pop    %ebp
  8002ea:	c3                   	ret    

008002eb <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002eb:	55                   	push   %ebp
  8002ec:	89 e5                	mov    %esp,%ebp
  8002ee:	57                   	push   %edi
  8002ef:	56                   	push   %esi
  8002f0:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002f1:	be 00 00 00 00       	mov    $0x0,%esi
  8002f6:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800301:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800304:	8b 7d 14             	mov    0x14(%ebp),%edi
  800307:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800309:	5b                   	pop    %ebx
  80030a:	5e                   	pop    %esi
  80030b:	5f                   	pop    %edi
  80030c:	5d                   	pop    %ebp
  80030d:	c3                   	ret    

0080030e <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80030e:	55                   	push   %ebp
  80030f:	89 e5                	mov    %esp,%ebp
  800311:	57                   	push   %edi
  800312:	56                   	push   %esi
  800313:	53                   	push   %ebx
  800314:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800317:	b9 00 00 00 00       	mov    $0x0,%ecx
  80031c:	b8 0d 00 00 00       	mov    $0xd,%eax
  800321:	8b 55 08             	mov    0x8(%ebp),%edx
  800324:	89 cb                	mov    %ecx,%ebx
  800326:	89 cf                	mov    %ecx,%edi
  800328:	89 ce                	mov    %ecx,%esi
  80032a:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80032c:	85 c0                	test   %eax,%eax
  80032e:	7e 17                	jle    800347 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800330:	83 ec 0c             	sub    $0xc,%esp
  800333:	50                   	push   %eax
  800334:	6a 0d                	push   $0xd
  800336:	68 ea 1d 80 00       	push   $0x801dea
  80033b:	6a 23                	push   $0x23
  80033d:	68 07 1e 80 00       	push   $0x801e07
  800342:	e8 eb 0c 00 00       	call   801032 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800347:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034a:	5b                   	pop    %ebx
  80034b:	5e                   	pop    %esi
  80034c:	5f                   	pop    %edi
  80034d:	5d                   	pop    %ebp
  80034e:	c3                   	ret    

0080034f <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80034f:	55                   	push   %ebp
  800350:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800352:	8b 45 08             	mov    0x8(%ebp),%eax
  800355:	05 00 00 00 30       	add    $0x30000000,%eax
  80035a:	c1 e8 0c             	shr    $0xc,%eax
}
  80035d:	5d                   	pop    %ebp
  80035e:	c3                   	ret    

0080035f <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80035f:	55                   	push   %ebp
  800360:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800362:	8b 45 08             	mov    0x8(%ebp),%eax
  800365:	05 00 00 00 30       	add    $0x30000000,%eax
  80036a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80036f:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800374:	5d                   	pop    %ebp
  800375:	c3                   	ret    

00800376 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800376:	55                   	push   %ebp
  800377:	89 e5                	mov    %esp,%ebp
  800379:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80037c:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800381:	89 c2                	mov    %eax,%edx
  800383:	c1 ea 16             	shr    $0x16,%edx
  800386:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  80038d:	f6 c2 01             	test   $0x1,%dl
  800390:	74 11                	je     8003a3 <fd_alloc+0x2d>
  800392:	89 c2                	mov    %eax,%edx
  800394:	c1 ea 0c             	shr    $0xc,%edx
  800397:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  80039e:	f6 c2 01             	test   $0x1,%dl
  8003a1:	75 09                	jne    8003ac <fd_alloc+0x36>
			*fd_store = fd;
  8003a3:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003a5:	b8 00 00 00 00       	mov    $0x0,%eax
  8003aa:	eb 17                	jmp    8003c3 <fd_alloc+0x4d>
  8003ac:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b1:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003b6:	75 c9                	jne    800381 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003b8:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003be:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c3:	5d                   	pop    %ebp
  8003c4:	c3                   	ret    

008003c5 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003c5:	55                   	push   %ebp
  8003c6:	89 e5                	mov    %esp,%ebp
  8003c8:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003cb:	83 f8 1f             	cmp    $0x1f,%eax
  8003ce:	77 36                	ja     800406 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d0:	c1 e0 0c             	shl    $0xc,%eax
  8003d3:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003d8:	89 c2                	mov    %eax,%edx
  8003da:	c1 ea 16             	shr    $0x16,%edx
  8003dd:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e4:	f6 c2 01             	test   $0x1,%dl
  8003e7:	74 24                	je     80040d <fd_lookup+0x48>
  8003e9:	89 c2                	mov    %eax,%edx
  8003eb:	c1 ea 0c             	shr    $0xc,%edx
  8003ee:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003f5:	f6 c2 01             	test   $0x1,%dl
  8003f8:	74 1a                	je     800414 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  8003fd:	89 02                	mov    %eax,(%edx)
	return 0;
  8003ff:	b8 00 00 00 00       	mov    $0x0,%eax
  800404:	eb 13                	jmp    800419 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800406:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80040b:	eb 0c                	jmp    800419 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040d:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800412:	eb 05                	jmp    800419 <fd_lookup+0x54>
  800414:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800419:	5d                   	pop    %ebp
  80041a:	c3                   	ret    

0080041b <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  80041b:	55                   	push   %ebp
  80041c:	89 e5                	mov    %esp,%ebp
  80041e:	83 ec 08             	sub    $0x8,%esp
  800421:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800424:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800429:	eb 13                	jmp    80043e <dev_lookup+0x23>
  80042b:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80042e:	39 08                	cmp    %ecx,(%eax)
  800430:	75 0c                	jne    80043e <dev_lookup+0x23>
			*dev = devtab[i];
  800432:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800435:	89 01                	mov    %eax,(%ecx)
			return 0;
  800437:	b8 00 00 00 00       	mov    $0x0,%eax
  80043c:	eb 2e                	jmp    80046c <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80043e:	8b 02                	mov    (%edx),%eax
  800440:	85 c0                	test   %eax,%eax
  800442:	75 e7                	jne    80042b <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800444:	a1 04 40 80 00       	mov    0x804004,%eax
  800449:	8b 40 48             	mov    0x48(%eax),%eax
  80044c:	83 ec 04             	sub    $0x4,%esp
  80044f:	51                   	push   %ecx
  800450:	50                   	push   %eax
  800451:	68 18 1e 80 00       	push   $0x801e18
  800456:	e8 b0 0c 00 00       	call   80110b <cprintf>
	*dev = 0;
  80045b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80045e:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800464:	83 c4 10             	add    $0x10,%esp
  800467:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  80046c:	c9                   	leave  
  80046d:	c3                   	ret    

0080046e <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80046e:	55                   	push   %ebp
  80046f:	89 e5                	mov    %esp,%ebp
  800471:	56                   	push   %esi
  800472:	53                   	push   %ebx
  800473:	83 ec 10             	sub    $0x10,%esp
  800476:	8b 75 08             	mov    0x8(%ebp),%esi
  800479:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  80047c:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80047f:	50                   	push   %eax
  800480:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800486:	c1 e8 0c             	shr    $0xc,%eax
  800489:	50                   	push   %eax
  80048a:	e8 36 ff ff ff       	call   8003c5 <fd_lookup>
  80048f:	83 c4 08             	add    $0x8,%esp
  800492:	85 c0                	test   %eax,%eax
  800494:	78 05                	js     80049b <fd_close+0x2d>
	    || fd != fd2)
  800496:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  800499:	74 0c                	je     8004a7 <fd_close+0x39>
		return (must_exist ? r : 0);
  80049b:	84 db                	test   %bl,%bl
  80049d:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a2:	0f 44 c2             	cmove  %edx,%eax
  8004a5:	eb 41                	jmp    8004e8 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004a7:	83 ec 08             	sub    $0x8,%esp
  8004aa:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004ad:	50                   	push   %eax
  8004ae:	ff 36                	pushl  (%esi)
  8004b0:	e8 66 ff ff ff       	call   80041b <dev_lookup>
  8004b5:	89 c3                	mov    %eax,%ebx
  8004b7:	83 c4 10             	add    $0x10,%esp
  8004ba:	85 c0                	test   %eax,%eax
  8004bc:	78 1a                	js     8004d8 <fd_close+0x6a>
		if (dev->dev_close)
  8004be:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c1:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c4:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004c9:	85 c0                	test   %eax,%eax
  8004cb:	74 0b                	je     8004d8 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004cd:	83 ec 0c             	sub    $0xc,%esp
  8004d0:	56                   	push   %esi
  8004d1:	ff d0                	call   *%eax
  8004d3:	89 c3                	mov    %eax,%ebx
  8004d5:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004d8:	83 ec 08             	sub    $0x8,%esp
  8004db:	56                   	push   %esi
  8004dc:	6a 00                	push   $0x0
  8004de:	e8 00 fd ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  8004e3:	83 c4 10             	add    $0x10,%esp
  8004e6:	89 d8                	mov    %ebx,%eax
}
  8004e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004eb:	5b                   	pop    %ebx
  8004ec:	5e                   	pop    %esi
  8004ed:	5d                   	pop    %ebp
  8004ee:	c3                   	ret    

008004ef <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004ef:	55                   	push   %ebp
  8004f0:	89 e5                	mov    %esp,%ebp
  8004f2:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004f5:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004f8:	50                   	push   %eax
  8004f9:	ff 75 08             	pushl  0x8(%ebp)
  8004fc:	e8 c4 fe ff ff       	call   8003c5 <fd_lookup>
  800501:	83 c4 08             	add    $0x8,%esp
  800504:	85 c0                	test   %eax,%eax
  800506:	78 10                	js     800518 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800508:	83 ec 08             	sub    $0x8,%esp
  80050b:	6a 01                	push   $0x1
  80050d:	ff 75 f4             	pushl  -0xc(%ebp)
  800510:	e8 59 ff ff ff       	call   80046e <fd_close>
  800515:	83 c4 10             	add    $0x10,%esp
}
  800518:	c9                   	leave  
  800519:	c3                   	ret    

0080051a <close_all>:

void
close_all(void)
{
  80051a:	55                   	push   %ebp
  80051b:	89 e5                	mov    %esp,%ebp
  80051d:	53                   	push   %ebx
  80051e:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800521:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800526:	83 ec 0c             	sub    $0xc,%esp
  800529:	53                   	push   %ebx
  80052a:	e8 c0 ff ff ff       	call   8004ef <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80052f:	83 c3 01             	add    $0x1,%ebx
  800532:	83 c4 10             	add    $0x10,%esp
  800535:	83 fb 20             	cmp    $0x20,%ebx
  800538:	75 ec                	jne    800526 <close_all+0xc>
		close(i);
}
  80053a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80053d:	c9                   	leave  
  80053e:	c3                   	ret    

0080053f <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80053f:	55                   	push   %ebp
  800540:	89 e5                	mov    %esp,%ebp
  800542:	57                   	push   %edi
  800543:	56                   	push   %esi
  800544:	53                   	push   %ebx
  800545:	83 ec 2c             	sub    $0x2c,%esp
  800548:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  80054b:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80054e:	50                   	push   %eax
  80054f:	ff 75 08             	pushl  0x8(%ebp)
  800552:	e8 6e fe ff ff       	call   8003c5 <fd_lookup>
  800557:	83 c4 08             	add    $0x8,%esp
  80055a:	85 c0                	test   %eax,%eax
  80055c:	0f 88 c1 00 00 00    	js     800623 <dup+0xe4>
		return r;
	close(newfdnum);
  800562:	83 ec 0c             	sub    $0xc,%esp
  800565:	56                   	push   %esi
  800566:	e8 84 ff ff ff       	call   8004ef <close>

	newfd = INDEX2FD(newfdnum);
  80056b:	89 f3                	mov    %esi,%ebx
  80056d:	c1 e3 0c             	shl    $0xc,%ebx
  800570:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800576:	83 c4 04             	add    $0x4,%esp
  800579:	ff 75 e4             	pushl  -0x1c(%ebp)
  80057c:	e8 de fd ff ff       	call   80035f <fd2data>
  800581:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800583:	89 1c 24             	mov    %ebx,(%esp)
  800586:	e8 d4 fd ff ff       	call   80035f <fd2data>
  80058b:	83 c4 10             	add    $0x10,%esp
  80058e:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800591:	89 f8                	mov    %edi,%eax
  800593:	c1 e8 16             	shr    $0x16,%eax
  800596:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  80059d:	a8 01                	test   $0x1,%al
  80059f:	74 37                	je     8005d8 <dup+0x99>
  8005a1:	89 f8                	mov    %edi,%eax
  8005a3:	c1 e8 0c             	shr    $0xc,%eax
  8005a6:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005ad:	f6 c2 01             	test   $0x1,%dl
  8005b0:	74 26                	je     8005d8 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b2:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005b9:	83 ec 0c             	sub    $0xc,%esp
  8005bc:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c1:	50                   	push   %eax
  8005c2:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005c5:	6a 00                	push   $0x0
  8005c7:	57                   	push   %edi
  8005c8:	6a 00                	push   $0x0
  8005ca:	e8 d2 fb ff ff       	call   8001a1 <sys_page_map>
  8005cf:	89 c7                	mov    %eax,%edi
  8005d1:	83 c4 20             	add    $0x20,%esp
  8005d4:	85 c0                	test   %eax,%eax
  8005d6:	78 2e                	js     800606 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005d8:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005db:	89 d0                	mov    %edx,%eax
  8005dd:	c1 e8 0c             	shr    $0xc,%eax
  8005e0:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005e7:	83 ec 0c             	sub    $0xc,%esp
  8005ea:	25 07 0e 00 00       	and    $0xe07,%eax
  8005ef:	50                   	push   %eax
  8005f0:	53                   	push   %ebx
  8005f1:	6a 00                	push   $0x0
  8005f3:	52                   	push   %edx
  8005f4:	6a 00                	push   $0x0
  8005f6:	e8 a6 fb ff ff       	call   8001a1 <sys_page_map>
  8005fb:	89 c7                	mov    %eax,%edi
  8005fd:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800600:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800602:	85 ff                	test   %edi,%edi
  800604:	79 1d                	jns    800623 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800606:	83 ec 08             	sub    $0x8,%esp
  800609:	53                   	push   %ebx
  80060a:	6a 00                	push   $0x0
  80060c:	e8 d2 fb ff ff       	call   8001e3 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800611:	83 c4 08             	add    $0x8,%esp
  800614:	ff 75 d4             	pushl  -0x2c(%ebp)
  800617:	6a 00                	push   $0x0
  800619:	e8 c5 fb ff ff       	call   8001e3 <sys_page_unmap>
	return r;
  80061e:	83 c4 10             	add    $0x10,%esp
  800621:	89 f8                	mov    %edi,%eax
}
  800623:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800626:	5b                   	pop    %ebx
  800627:	5e                   	pop    %esi
  800628:	5f                   	pop    %edi
  800629:	5d                   	pop    %ebp
  80062a:	c3                   	ret    

0080062b <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  80062b:	55                   	push   %ebp
  80062c:	89 e5                	mov    %esp,%ebp
  80062e:	53                   	push   %ebx
  80062f:	83 ec 14             	sub    $0x14,%esp
  800632:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800635:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800638:	50                   	push   %eax
  800639:	53                   	push   %ebx
  80063a:	e8 86 fd ff ff       	call   8003c5 <fd_lookup>
  80063f:	83 c4 08             	add    $0x8,%esp
  800642:	89 c2                	mov    %eax,%edx
  800644:	85 c0                	test   %eax,%eax
  800646:	78 6d                	js     8006b5 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800648:	83 ec 08             	sub    $0x8,%esp
  80064b:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80064e:	50                   	push   %eax
  80064f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800652:	ff 30                	pushl  (%eax)
  800654:	e8 c2 fd ff ff       	call   80041b <dev_lookup>
  800659:	83 c4 10             	add    $0x10,%esp
  80065c:	85 c0                	test   %eax,%eax
  80065e:	78 4c                	js     8006ac <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800660:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800663:	8b 42 08             	mov    0x8(%edx),%eax
  800666:	83 e0 03             	and    $0x3,%eax
  800669:	83 f8 01             	cmp    $0x1,%eax
  80066c:	75 21                	jne    80068f <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80066e:	a1 04 40 80 00       	mov    0x804004,%eax
  800673:	8b 40 48             	mov    0x48(%eax),%eax
  800676:	83 ec 04             	sub    $0x4,%esp
  800679:	53                   	push   %ebx
  80067a:	50                   	push   %eax
  80067b:	68 59 1e 80 00       	push   $0x801e59
  800680:	e8 86 0a 00 00       	call   80110b <cprintf>
		return -E_INVAL;
  800685:	83 c4 10             	add    $0x10,%esp
  800688:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80068d:	eb 26                	jmp    8006b5 <read+0x8a>
	}
	if (!dev->dev_read)
  80068f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800692:	8b 40 08             	mov    0x8(%eax),%eax
  800695:	85 c0                	test   %eax,%eax
  800697:	74 17                	je     8006b0 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  800699:	83 ec 04             	sub    $0x4,%esp
  80069c:	ff 75 10             	pushl  0x10(%ebp)
  80069f:	ff 75 0c             	pushl  0xc(%ebp)
  8006a2:	52                   	push   %edx
  8006a3:	ff d0                	call   *%eax
  8006a5:	89 c2                	mov    %eax,%edx
  8006a7:	83 c4 10             	add    $0x10,%esp
  8006aa:	eb 09                	jmp    8006b5 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006ac:	89 c2                	mov    %eax,%edx
  8006ae:	eb 05                	jmp    8006b5 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b0:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006b5:	89 d0                	mov    %edx,%eax
  8006b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006ba:	c9                   	leave  
  8006bb:	c3                   	ret    

008006bc <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006bc:	55                   	push   %ebp
  8006bd:	89 e5                	mov    %esp,%ebp
  8006bf:	57                   	push   %edi
  8006c0:	56                   	push   %esi
  8006c1:	53                   	push   %ebx
  8006c2:	83 ec 0c             	sub    $0xc,%esp
  8006c5:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006c8:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006cb:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d0:	eb 21                	jmp    8006f3 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d2:	83 ec 04             	sub    $0x4,%esp
  8006d5:	89 f0                	mov    %esi,%eax
  8006d7:	29 d8                	sub    %ebx,%eax
  8006d9:	50                   	push   %eax
  8006da:	89 d8                	mov    %ebx,%eax
  8006dc:	03 45 0c             	add    0xc(%ebp),%eax
  8006df:	50                   	push   %eax
  8006e0:	57                   	push   %edi
  8006e1:	e8 45 ff ff ff       	call   80062b <read>
		if (m < 0)
  8006e6:	83 c4 10             	add    $0x10,%esp
  8006e9:	85 c0                	test   %eax,%eax
  8006eb:	78 10                	js     8006fd <readn+0x41>
			return m;
		if (m == 0)
  8006ed:	85 c0                	test   %eax,%eax
  8006ef:	74 0a                	je     8006fb <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f1:	01 c3                	add    %eax,%ebx
  8006f3:	39 f3                	cmp    %esi,%ebx
  8006f5:	72 db                	jb     8006d2 <readn+0x16>
  8006f7:	89 d8                	mov    %ebx,%eax
  8006f9:	eb 02                	jmp    8006fd <readn+0x41>
  8006fb:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  8006fd:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800700:	5b                   	pop    %ebx
  800701:	5e                   	pop    %esi
  800702:	5f                   	pop    %edi
  800703:	5d                   	pop    %ebp
  800704:	c3                   	ret    

00800705 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800705:	55                   	push   %ebp
  800706:	89 e5                	mov    %esp,%ebp
  800708:	53                   	push   %ebx
  800709:	83 ec 14             	sub    $0x14,%esp
  80070c:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80070f:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800712:	50                   	push   %eax
  800713:	53                   	push   %ebx
  800714:	e8 ac fc ff ff       	call   8003c5 <fd_lookup>
  800719:	83 c4 08             	add    $0x8,%esp
  80071c:	89 c2                	mov    %eax,%edx
  80071e:	85 c0                	test   %eax,%eax
  800720:	78 68                	js     80078a <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800722:	83 ec 08             	sub    $0x8,%esp
  800725:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800728:	50                   	push   %eax
  800729:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80072c:	ff 30                	pushl  (%eax)
  80072e:	e8 e8 fc ff ff       	call   80041b <dev_lookup>
  800733:	83 c4 10             	add    $0x10,%esp
  800736:	85 c0                	test   %eax,%eax
  800738:	78 47                	js     800781 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80073d:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800741:	75 21                	jne    800764 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800743:	a1 04 40 80 00       	mov    0x804004,%eax
  800748:	8b 40 48             	mov    0x48(%eax),%eax
  80074b:	83 ec 04             	sub    $0x4,%esp
  80074e:	53                   	push   %ebx
  80074f:	50                   	push   %eax
  800750:	68 75 1e 80 00       	push   $0x801e75
  800755:	e8 b1 09 00 00       	call   80110b <cprintf>
		return -E_INVAL;
  80075a:	83 c4 10             	add    $0x10,%esp
  80075d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800762:	eb 26                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800764:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800767:	8b 52 0c             	mov    0xc(%edx),%edx
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 17                	je     800785 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80076e:	83 ec 04             	sub    $0x4,%esp
  800771:	ff 75 10             	pushl  0x10(%ebp)
  800774:	ff 75 0c             	pushl  0xc(%ebp)
  800777:	50                   	push   %eax
  800778:	ff d2                	call   *%edx
  80077a:	89 c2                	mov    %eax,%edx
  80077c:	83 c4 10             	add    $0x10,%esp
  80077f:	eb 09                	jmp    80078a <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800781:	89 c2                	mov    %eax,%edx
  800783:	eb 05                	jmp    80078a <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800785:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078a:	89 d0                	mov    %edx,%eax
  80078c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80078f:	c9                   	leave  
  800790:	c3                   	ret    

00800791 <seek>:

int
seek(int fdnum, off_t offset)
{
  800791:	55                   	push   %ebp
  800792:	89 e5                	mov    %esp,%ebp
  800794:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800797:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079a:	50                   	push   %eax
  80079b:	ff 75 08             	pushl  0x8(%ebp)
  80079e:	e8 22 fc ff ff       	call   8003c5 <fd_lookup>
  8007a3:	83 c4 08             	add    $0x8,%esp
  8007a6:	85 c0                	test   %eax,%eax
  8007a8:	78 0e                	js     8007b8 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007aa:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007ad:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b0:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007b8:	c9                   	leave  
  8007b9:	c3                   	ret    

008007ba <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007ba:	55                   	push   %ebp
  8007bb:	89 e5                	mov    %esp,%ebp
  8007bd:	53                   	push   %ebx
  8007be:	83 ec 14             	sub    $0x14,%esp
  8007c1:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c4:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007c7:	50                   	push   %eax
  8007c8:	53                   	push   %ebx
  8007c9:	e8 f7 fb ff ff       	call   8003c5 <fd_lookup>
  8007ce:	83 c4 08             	add    $0x8,%esp
  8007d1:	89 c2                	mov    %eax,%edx
  8007d3:	85 c0                	test   %eax,%eax
  8007d5:	78 65                	js     80083c <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007d7:	83 ec 08             	sub    $0x8,%esp
  8007da:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007dd:	50                   	push   %eax
  8007de:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e1:	ff 30                	pushl  (%eax)
  8007e3:	e8 33 fc ff ff       	call   80041b <dev_lookup>
  8007e8:	83 c4 10             	add    $0x10,%esp
  8007eb:	85 c0                	test   %eax,%eax
  8007ed:	78 44                	js     800833 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007ef:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f2:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007f6:	75 21                	jne    800819 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007f8:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  8007fd:	8b 40 48             	mov    0x48(%eax),%eax
  800800:	83 ec 04             	sub    $0x4,%esp
  800803:	53                   	push   %ebx
  800804:	50                   	push   %eax
  800805:	68 38 1e 80 00       	push   $0x801e38
  80080a:	e8 fc 08 00 00       	call   80110b <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80080f:	83 c4 10             	add    $0x10,%esp
  800812:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800817:	eb 23                	jmp    80083c <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800819:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80081c:	8b 52 18             	mov    0x18(%edx),%edx
  80081f:	85 d2                	test   %edx,%edx
  800821:	74 14                	je     800837 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800823:	83 ec 08             	sub    $0x8,%esp
  800826:	ff 75 0c             	pushl  0xc(%ebp)
  800829:	50                   	push   %eax
  80082a:	ff d2                	call   *%edx
  80082c:	89 c2                	mov    %eax,%edx
  80082e:	83 c4 10             	add    $0x10,%esp
  800831:	eb 09                	jmp    80083c <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800833:	89 c2                	mov    %eax,%edx
  800835:	eb 05                	jmp    80083c <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800837:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  80083c:	89 d0                	mov    %edx,%eax
  80083e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800841:	c9                   	leave  
  800842:	c3                   	ret    

00800843 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800843:	55                   	push   %ebp
  800844:	89 e5                	mov    %esp,%ebp
  800846:	53                   	push   %ebx
  800847:	83 ec 14             	sub    $0x14,%esp
  80084a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80084d:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800850:	50                   	push   %eax
  800851:	ff 75 08             	pushl  0x8(%ebp)
  800854:	e8 6c fb ff ff       	call   8003c5 <fd_lookup>
  800859:	83 c4 08             	add    $0x8,%esp
  80085c:	89 c2                	mov    %eax,%edx
  80085e:	85 c0                	test   %eax,%eax
  800860:	78 58                	js     8008ba <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800862:	83 ec 08             	sub    $0x8,%esp
  800865:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800868:	50                   	push   %eax
  800869:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80086c:	ff 30                	pushl  (%eax)
  80086e:	e8 a8 fb ff ff       	call   80041b <dev_lookup>
  800873:	83 c4 10             	add    $0x10,%esp
  800876:	85 c0                	test   %eax,%eax
  800878:	78 37                	js     8008b1 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087a:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80087d:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800881:	74 32                	je     8008b5 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800883:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800886:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  80088d:	00 00 00 
	stat->st_isdir = 0;
  800890:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800897:	00 00 00 
	stat->st_dev = dev;
  80089a:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a0:	83 ec 08             	sub    $0x8,%esp
  8008a3:	53                   	push   %ebx
  8008a4:	ff 75 f0             	pushl  -0x10(%ebp)
  8008a7:	ff 50 14             	call   *0x14(%eax)
  8008aa:	89 c2                	mov    %eax,%edx
  8008ac:	83 c4 10             	add    $0x10,%esp
  8008af:	eb 09                	jmp    8008ba <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b1:	89 c2                	mov    %eax,%edx
  8008b3:	eb 05                	jmp    8008ba <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008ba:	89 d0                	mov    %edx,%eax
  8008bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008bf:	c9                   	leave  
  8008c0:	c3                   	ret    

008008c1 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c1:	55                   	push   %ebp
  8008c2:	89 e5                	mov    %esp,%ebp
  8008c4:	56                   	push   %esi
  8008c5:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008c6:	83 ec 08             	sub    $0x8,%esp
  8008c9:	6a 00                	push   $0x0
  8008cb:	ff 75 08             	pushl  0x8(%ebp)
  8008ce:	e8 dc 01 00 00       	call   800aaf <open>
  8008d3:	89 c3                	mov    %eax,%ebx
  8008d5:	83 c4 10             	add    $0x10,%esp
  8008d8:	85 c0                	test   %eax,%eax
  8008da:	78 1b                	js     8008f7 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008dc:	83 ec 08             	sub    $0x8,%esp
  8008df:	ff 75 0c             	pushl  0xc(%ebp)
  8008e2:	50                   	push   %eax
  8008e3:	e8 5b ff ff ff       	call   800843 <fstat>
  8008e8:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ea:	89 1c 24             	mov    %ebx,(%esp)
  8008ed:	e8 fd fb ff ff       	call   8004ef <close>
	return r;
  8008f2:	83 c4 10             	add    $0x10,%esp
  8008f5:	89 f0                	mov    %esi,%eax
}
  8008f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008fa:	5b                   	pop    %ebx
  8008fb:	5e                   	pop    %esi
  8008fc:	5d                   	pop    %ebp
  8008fd:	c3                   	ret    

008008fe <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  8008fe:	55                   	push   %ebp
  8008ff:	89 e5                	mov    %esp,%ebp
  800901:	56                   	push   %esi
  800902:	53                   	push   %ebx
  800903:	89 c6                	mov    %eax,%esi
  800905:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800907:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80090e:	75 12                	jne    800922 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800910:	83 ec 0c             	sub    $0xc,%esp
  800913:	6a 01                	push   $0x1
  800915:	e8 a7 11 00 00       	call   801ac1 <ipc_find_env>
  80091a:	a3 00 40 80 00       	mov    %eax,0x804000
  80091f:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800922:	6a 07                	push   $0x7
  800924:	68 00 50 80 00       	push   $0x805000
  800929:	56                   	push   %esi
  80092a:	ff 35 00 40 80 00    	pushl  0x804000
  800930:	e8 49 11 00 00       	call   801a7e <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  800935:	83 c4 0c             	add    $0xc,%esp
  800938:	6a 00                	push   $0x0
  80093a:	53                   	push   %ebx
  80093b:	6a 00                	push   $0x0
  80093d:	e8 df 10 00 00       	call   801a21 <ipc_recv>
}
  800942:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800945:	5b                   	pop    %ebx
  800946:	5e                   	pop    %esi
  800947:	5d                   	pop    %ebp
  800948:	c3                   	ret    

00800949 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800949:	55                   	push   %ebp
  80094a:	89 e5                	mov    %esp,%ebp
  80094c:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80094f:	8b 45 08             	mov    0x8(%ebp),%eax
  800952:	8b 40 0c             	mov    0xc(%eax),%eax
  800955:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095a:	8b 45 0c             	mov    0xc(%ebp),%eax
  80095d:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800962:	ba 00 00 00 00       	mov    $0x0,%edx
  800967:	b8 02 00 00 00       	mov    $0x2,%eax
  80096c:	e8 8d ff ff ff       	call   8008fe <fsipc>
}
  800971:	c9                   	leave  
  800972:	c3                   	ret    

00800973 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800973:	55                   	push   %ebp
  800974:	89 e5                	mov    %esp,%ebp
  800976:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800979:	8b 45 08             	mov    0x8(%ebp),%eax
  80097c:	8b 40 0c             	mov    0xc(%eax),%eax
  80097f:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800984:	ba 00 00 00 00       	mov    $0x0,%edx
  800989:	b8 06 00 00 00       	mov    $0x6,%eax
  80098e:	e8 6b ff ff ff       	call   8008fe <fsipc>
}
  800993:	c9                   	leave  
  800994:	c3                   	ret    

00800995 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  800995:	55                   	push   %ebp
  800996:	89 e5                	mov    %esp,%ebp
  800998:	53                   	push   %ebx
  800999:	83 ec 04             	sub    $0x4,%esp
  80099c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  80099f:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a2:	8b 40 0c             	mov    0xc(%eax),%eax
  8009a5:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009aa:	ba 00 00 00 00       	mov    $0x0,%edx
  8009af:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b4:	e8 45 ff ff ff       	call   8008fe <fsipc>
  8009b9:	85 c0                	test   %eax,%eax
  8009bb:	78 2c                	js     8009e9 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009bd:	83 ec 08             	sub    $0x8,%esp
  8009c0:	68 00 50 80 00       	push   $0x805000
  8009c5:	53                   	push   %ebx
  8009c6:	e8 0f 0d 00 00       	call   8016da <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009cb:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d0:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009d6:	a1 84 50 80 00       	mov    0x805084,%eax
  8009db:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e1:	83 c4 10             	add    $0x10,%esp
  8009e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009e9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009ec:	c9                   	leave  
  8009ed:	c3                   	ret    

008009ee <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009ee:	55                   	push   %ebp
  8009ef:	89 e5                	mov    %esp,%ebp
  8009f1:	83 ec 0c             	sub    $0xc,%esp
  8009f4:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8009fa:	8b 52 0c             	mov    0xc(%edx),%edx
  8009fd:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a03:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a08:	50                   	push   %eax
  800a09:	ff 75 0c             	pushl  0xc(%ebp)
  800a0c:	68 08 50 80 00       	push   $0x805008
  800a11:	e8 56 0e 00 00       	call   80186c <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a16:	ba 00 00 00 00       	mov    $0x0,%edx
  800a1b:	b8 04 00 00 00       	mov    $0x4,%eax
  800a20:	e8 d9 fe ff ff       	call   8008fe <fsipc>
	//panic("devfile_write not implemented");
}
  800a25:	c9                   	leave  
  800a26:	c3                   	ret    

00800a27 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a27:	55                   	push   %ebp
  800a28:	89 e5                	mov    %esp,%ebp
  800a2a:	56                   	push   %esi
  800a2b:	53                   	push   %ebx
  800a2c:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a2f:	8b 45 08             	mov    0x8(%ebp),%eax
  800a32:	8b 40 0c             	mov    0xc(%eax),%eax
  800a35:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3a:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a40:	ba 00 00 00 00       	mov    $0x0,%edx
  800a45:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4a:	e8 af fe ff ff       	call   8008fe <fsipc>
  800a4f:	89 c3                	mov    %eax,%ebx
  800a51:	85 c0                	test   %eax,%eax
  800a53:	78 51                	js     800aa6 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a55:	39 c6                	cmp    %eax,%esi
  800a57:	73 19                	jae    800a72 <devfile_read+0x4b>
  800a59:	68 a4 1e 80 00       	push   $0x801ea4
  800a5e:	68 ab 1e 80 00       	push   $0x801eab
  800a63:	68 80 00 00 00       	push   $0x80
  800a68:	68 c0 1e 80 00       	push   $0x801ec0
  800a6d:	e8 c0 05 00 00       	call   801032 <_panic>
	assert(r <= PGSIZE);
  800a72:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a77:	7e 19                	jle    800a92 <devfile_read+0x6b>
  800a79:	68 cb 1e 80 00       	push   $0x801ecb
  800a7e:	68 ab 1e 80 00       	push   $0x801eab
  800a83:	68 81 00 00 00       	push   $0x81
  800a88:	68 c0 1e 80 00       	push   $0x801ec0
  800a8d:	e8 a0 05 00 00       	call   801032 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a92:	83 ec 04             	sub    $0x4,%esp
  800a95:	50                   	push   %eax
  800a96:	68 00 50 80 00       	push   $0x805000
  800a9b:	ff 75 0c             	pushl  0xc(%ebp)
  800a9e:	e8 c9 0d 00 00       	call   80186c <memmove>
	return r;
  800aa3:	83 c4 10             	add    $0x10,%esp
}
  800aa6:	89 d8                	mov    %ebx,%eax
  800aa8:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800aab:	5b                   	pop    %ebx
  800aac:	5e                   	pop    %esi
  800aad:	5d                   	pop    %ebp
  800aae:	c3                   	ret    

00800aaf <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800aaf:	55                   	push   %ebp
  800ab0:	89 e5                	mov    %esp,%ebp
  800ab2:	53                   	push   %ebx
  800ab3:	83 ec 20             	sub    $0x20,%esp
  800ab6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ab9:	53                   	push   %ebx
  800aba:	e8 e2 0b 00 00       	call   8016a1 <strlen>
  800abf:	83 c4 10             	add    $0x10,%esp
  800ac2:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ac7:	7f 67                	jg     800b30 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ac9:	83 ec 0c             	sub    $0xc,%esp
  800acc:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800acf:	50                   	push   %eax
  800ad0:	e8 a1 f8 ff ff       	call   800376 <fd_alloc>
  800ad5:	83 c4 10             	add    $0x10,%esp
		return r;
  800ad8:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ada:	85 c0                	test   %eax,%eax
  800adc:	78 57                	js     800b35 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ade:	83 ec 08             	sub    $0x8,%esp
  800ae1:	53                   	push   %ebx
  800ae2:	68 00 50 80 00       	push   $0x805000
  800ae7:	e8 ee 0b 00 00       	call   8016da <strcpy>
	fsipcbuf.open.req_omode = mode;
  800aec:	8b 45 0c             	mov    0xc(%ebp),%eax
  800aef:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af4:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800af7:	b8 01 00 00 00       	mov    $0x1,%eax
  800afc:	e8 fd fd ff ff       	call   8008fe <fsipc>
  800b01:	89 c3                	mov    %eax,%ebx
  800b03:	83 c4 10             	add    $0x10,%esp
  800b06:	85 c0                	test   %eax,%eax
  800b08:	79 14                	jns    800b1e <open+0x6f>
		
		fd_close(fd, 0);
  800b0a:	83 ec 08             	sub    $0x8,%esp
  800b0d:	6a 00                	push   $0x0
  800b0f:	ff 75 f4             	pushl  -0xc(%ebp)
  800b12:	e8 57 f9 ff ff       	call   80046e <fd_close>
		return r;
  800b17:	83 c4 10             	add    $0x10,%esp
  800b1a:	89 da                	mov    %ebx,%edx
  800b1c:	eb 17                	jmp    800b35 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  800b1e:	83 ec 0c             	sub    $0xc,%esp
  800b21:	ff 75 f4             	pushl  -0xc(%ebp)
  800b24:	e8 26 f8 ff ff       	call   80034f <fd2num>
  800b29:	89 c2                	mov    %eax,%edx
  800b2b:	83 c4 10             	add    $0x10,%esp
  800b2e:	eb 05                	jmp    800b35 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b30:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  800b35:	89 d0                	mov    %edx,%eax
  800b37:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3a:	c9                   	leave  
  800b3b:	c3                   	ret    

00800b3c <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b3c:	55                   	push   %ebp
  800b3d:	89 e5                	mov    %esp,%ebp
  800b3f:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b42:	ba 00 00 00 00       	mov    $0x0,%edx
  800b47:	b8 08 00 00 00       	mov    $0x8,%eax
  800b4c:	e8 ad fd ff ff       	call   8008fe <fsipc>
}
  800b51:	c9                   	leave  
  800b52:	c3                   	ret    

00800b53 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b53:	55                   	push   %ebp
  800b54:	89 e5                	mov    %esp,%ebp
  800b56:	56                   	push   %esi
  800b57:	53                   	push   %ebx
  800b58:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b5b:	83 ec 0c             	sub    $0xc,%esp
  800b5e:	ff 75 08             	pushl  0x8(%ebp)
  800b61:	e8 f9 f7 ff ff       	call   80035f <fd2data>
  800b66:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b68:	83 c4 08             	add    $0x8,%esp
  800b6b:	68 d7 1e 80 00       	push   $0x801ed7
  800b70:	53                   	push   %ebx
  800b71:	e8 64 0b 00 00       	call   8016da <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b76:	8b 46 04             	mov    0x4(%esi),%eax
  800b79:	2b 06                	sub    (%esi),%eax
  800b7b:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b81:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b88:	00 00 00 
	stat->st_dev = &devpipe;
  800b8b:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b92:	30 80 00 
	return 0;
}
  800b95:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800b9d:	5b                   	pop    %ebx
  800b9e:	5e                   	pop    %esi
  800b9f:	5d                   	pop    %ebp
  800ba0:	c3                   	ret    

00800ba1 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba1:	55                   	push   %ebp
  800ba2:	89 e5                	mov    %esp,%ebp
  800ba4:	53                   	push   %ebx
  800ba5:	83 ec 0c             	sub    $0xc,%esp
  800ba8:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bab:	53                   	push   %ebx
  800bac:	6a 00                	push   $0x0
  800bae:	e8 30 f6 ff ff       	call   8001e3 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb3:	89 1c 24             	mov    %ebx,(%esp)
  800bb6:	e8 a4 f7 ff ff       	call   80035f <fd2data>
  800bbb:	83 c4 08             	add    $0x8,%esp
  800bbe:	50                   	push   %eax
  800bbf:	6a 00                	push   $0x0
  800bc1:	e8 1d f6 ff ff       	call   8001e3 <sys_page_unmap>
}
  800bc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bc9:	c9                   	leave  
  800bca:	c3                   	ret    

00800bcb <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bcb:	55                   	push   %ebp
  800bcc:	89 e5                	mov    %esp,%ebp
  800bce:	57                   	push   %edi
  800bcf:	56                   	push   %esi
  800bd0:	53                   	push   %ebx
  800bd1:	83 ec 1c             	sub    $0x1c,%esp
  800bd4:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bd7:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bd9:	a1 04 40 80 00       	mov    0x804004,%eax
  800bde:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800be1:	83 ec 0c             	sub    $0xc,%esp
  800be4:	ff 75 e0             	pushl  -0x20(%ebp)
  800be7:	e8 0e 0f 00 00       	call   801afa <pageref>
  800bec:	89 c3                	mov    %eax,%ebx
  800bee:	89 3c 24             	mov    %edi,(%esp)
  800bf1:	e8 04 0f 00 00       	call   801afa <pageref>
  800bf6:	83 c4 10             	add    $0x10,%esp
  800bf9:	39 c3                	cmp    %eax,%ebx
  800bfb:	0f 94 c1             	sete   %cl
  800bfe:	0f b6 c9             	movzbl %cl,%ecx
  800c01:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c04:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c0a:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c0d:	39 ce                	cmp    %ecx,%esi
  800c0f:	74 1b                	je     800c2c <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c11:	39 c3                	cmp    %eax,%ebx
  800c13:	75 c4                	jne    800bd9 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c15:	8b 42 58             	mov    0x58(%edx),%eax
  800c18:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c1b:	50                   	push   %eax
  800c1c:	56                   	push   %esi
  800c1d:	68 de 1e 80 00       	push   $0x801ede
  800c22:	e8 e4 04 00 00       	call   80110b <cprintf>
  800c27:	83 c4 10             	add    $0x10,%esp
  800c2a:	eb ad                	jmp    800bd9 <_pipeisclosed+0xe>
	}
}
  800c2c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c2f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c32:	5b                   	pop    %ebx
  800c33:	5e                   	pop    %esi
  800c34:	5f                   	pop    %edi
  800c35:	5d                   	pop    %ebp
  800c36:	c3                   	ret    

00800c37 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c37:	55                   	push   %ebp
  800c38:	89 e5                	mov    %esp,%ebp
  800c3a:	57                   	push   %edi
  800c3b:	56                   	push   %esi
  800c3c:	53                   	push   %ebx
  800c3d:	83 ec 28             	sub    $0x28,%esp
  800c40:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c43:	56                   	push   %esi
  800c44:	e8 16 f7 ff ff       	call   80035f <fd2data>
  800c49:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c4b:	83 c4 10             	add    $0x10,%esp
  800c4e:	bf 00 00 00 00       	mov    $0x0,%edi
  800c53:	eb 4b                	jmp    800ca0 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c55:	89 da                	mov    %ebx,%edx
  800c57:	89 f0                	mov    %esi,%eax
  800c59:	e8 6d ff ff ff       	call   800bcb <_pipeisclosed>
  800c5e:	85 c0                	test   %eax,%eax
  800c60:	75 48                	jne    800caa <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c62:	e8 d8 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c67:	8b 43 04             	mov    0x4(%ebx),%eax
  800c6a:	8b 0b                	mov    (%ebx),%ecx
  800c6c:	8d 51 20             	lea    0x20(%ecx),%edx
  800c6f:	39 d0                	cmp    %edx,%eax
  800c71:	73 e2                	jae    800c55 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c73:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c76:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c7a:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c7d:	89 c2                	mov    %eax,%edx
  800c7f:	c1 fa 1f             	sar    $0x1f,%edx
  800c82:	89 d1                	mov    %edx,%ecx
  800c84:	c1 e9 1b             	shr    $0x1b,%ecx
  800c87:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c8a:	83 e2 1f             	and    $0x1f,%edx
  800c8d:	29 ca                	sub    %ecx,%edx
  800c8f:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c93:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c97:	83 c0 01             	add    $0x1,%eax
  800c9a:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c9d:	83 c7 01             	add    $0x1,%edi
  800ca0:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca3:	75 c2                	jne    800c67 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800ca5:	8b 45 10             	mov    0x10(%ebp),%eax
  800ca8:	eb 05                	jmp    800caf <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800caa:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800caf:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb2:	5b                   	pop    %ebx
  800cb3:	5e                   	pop    %esi
  800cb4:	5f                   	pop    %edi
  800cb5:	5d                   	pop    %ebp
  800cb6:	c3                   	ret    

00800cb7 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cb7:	55                   	push   %ebp
  800cb8:	89 e5                	mov    %esp,%ebp
  800cba:	57                   	push   %edi
  800cbb:	56                   	push   %esi
  800cbc:	53                   	push   %ebx
  800cbd:	83 ec 18             	sub    $0x18,%esp
  800cc0:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc3:	57                   	push   %edi
  800cc4:	e8 96 f6 ff ff       	call   80035f <fd2data>
  800cc9:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ccb:	83 c4 10             	add    $0x10,%esp
  800cce:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd3:	eb 3d                	jmp    800d12 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cd5:	85 db                	test   %ebx,%ebx
  800cd7:	74 04                	je     800cdd <devpipe_read+0x26>
				return i;
  800cd9:	89 d8                	mov    %ebx,%eax
  800cdb:	eb 44                	jmp    800d21 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800cdd:	89 f2                	mov    %esi,%edx
  800cdf:	89 f8                	mov    %edi,%eax
  800ce1:	e8 e5 fe ff ff       	call   800bcb <_pipeisclosed>
  800ce6:	85 c0                	test   %eax,%eax
  800ce8:	75 32                	jne    800d1c <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cea:	e8 50 f4 ff ff       	call   80013f <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cef:	8b 06                	mov    (%esi),%eax
  800cf1:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf4:	74 df                	je     800cd5 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cf6:	99                   	cltd   
  800cf7:	c1 ea 1b             	shr    $0x1b,%edx
  800cfa:	01 d0                	add    %edx,%eax
  800cfc:	83 e0 1f             	and    $0x1f,%eax
  800cff:	29 d0                	sub    %edx,%eax
  800d01:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d09:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d0c:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d0f:	83 c3 01             	add    $0x1,%ebx
  800d12:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d15:	75 d8                	jne    800cef <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d17:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1a:	eb 05                	jmp    800d21 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d1c:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d21:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d24:	5b                   	pop    %ebx
  800d25:	5e                   	pop    %esi
  800d26:	5f                   	pop    %edi
  800d27:	5d                   	pop    %ebp
  800d28:	c3                   	ret    

00800d29 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d29:	55                   	push   %ebp
  800d2a:	89 e5                	mov    %esp,%ebp
  800d2c:	56                   	push   %esi
  800d2d:	53                   	push   %ebx
  800d2e:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d31:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d34:	50                   	push   %eax
  800d35:	e8 3c f6 ff ff       	call   800376 <fd_alloc>
  800d3a:	83 c4 10             	add    $0x10,%esp
  800d3d:	89 c2                	mov    %eax,%edx
  800d3f:	85 c0                	test   %eax,%eax
  800d41:	0f 88 2c 01 00 00    	js     800e73 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d47:	83 ec 04             	sub    $0x4,%esp
  800d4a:	68 07 04 00 00       	push   $0x407
  800d4f:	ff 75 f4             	pushl  -0xc(%ebp)
  800d52:	6a 00                	push   $0x0
  800d54:	e8 05 f4 ff ff       	call   80015e <sys_page_alloc>
  800d59:	83 c4 10             	add    $0x10,%esp
  800d5c:	89 c2                	mov    %eax,%edx
  800d5e:	85 c0                	test   %eax,%eax
  800d60:	0f 88 0d 01 00 00    	js     800e73 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d66:	83 ec 0c             	sub    $0xc,%esp
  800d69:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d6c:	50                   	push   %eax
  800d6d:	e8 04 f6 ff ff       	call   800376 <fd_alloc>
  800d72:	89 c3                	mov    %eax,%ebx
  800d74:	83 c4 10             	add    $0x10,%esp
  800d77:	85 c0                	test   %eax,%eax
  800d79:	0f 88 e2 00 00 00    	js     800e61 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d7f:	83 ec 04             	sub    $0x4,%esp
  800d82:	68 07 04 00 00       	push   $0x407
  800d87:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8a:	6a 00                	push   $0x0
  800d8c:	e8 cd f3 ff ff       	call   80015e <sys_page_alloc>
  800d91:	89 c3                	mov    %eax,%ebx
  800d93:	83 c4 10             	add    $0x10,%esp
  800d96:	85 c0                	test   %eax,%eax
  800d98:	0f 88 c3 00 00 00    	js     800e61 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800d9e:	83 ec 0c             	sub    $0xc,%esp
  800da1:	ff 75 f4             	pushl  -0xc(%ebp)
  800da4:	e8 b6 f5 ff ff       	call   80035f <fd2data>
  800da9:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dab:	83 c4 0c             	add    $0xc,%esp
  800dae:	68 07 04 00 00       	push   $0x407
  800db3:	50                   	push   %eax
  800db4:	6a 00                	push   $0x0
  800db6:	e8 a3 f3 ff ff       	call   80015e <sys_page_alloc>
  800dbb:	89 c3                	mov    %eax,%ebx
  800dbd:	83 c4 10             	add    $0x10,%esp
  800dc0:	85 c0                	test   %eax,%eax
  800dc2:	0f 88 89 00 00 00    	js     800e51 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dc8:	83 ec 0c             	sub    $0xc,%esp
  800dcb:	ff 75 f0             	pushl  -0x10(%ebp)
  800dce:	e8 8c f5 ff ff       	call   80035f <fd2data>
  800dd3:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800dda:	50                   	push   %eax
  800ddb:	6a 00                	push   $0x0
  800ddd:	56                   	push   %esi
  800dde:	6a 00                	push   $0x0
  800de0:	e8 bc f3 ff ff       	call   8001a1 <sys_page_map>
  800de5:	89 c3                	mov    %eax,%ebx
  800de7:	83 c4 20             	add    $0x20,%esp
  800dea:	85 c0                	test   %eax,%eax
  800dec:	78 55                	js     800e43 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dee:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df4:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800df7:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfc:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e03:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e09:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e0c:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e11:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e18:	83 ec 0c             	sub    $0xc,%esp
  800e1b:	ff 75 f4             	pushl  -0xc(%ebp)
  800e1e:	e8 2c f5 ff ff       	call   80034f <fd2num>
  800e23:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e26:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e28:	83 c4 04             	add    $0x4,%esp
  800e2b:	ff 75 f0             	pushl  -0x10(%ebp)
  800e2e:	e8 1c f5 ff ff       	call   80034f <fd2num>
  800e33:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e36:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e39:	83 c4 10             	add    $0x10,%esp
  800e3c:	ba 00 00 00 00       	mov    $0x0,%edx
  800e41:	eb 30                	jmp    800e73 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e43:	83 ec 08             	sub    $0x8,%esp
  800e46:	56                   	push   %esi
  800e47:	6a 00                	push   $0x0
  800e49:	e8 95 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e4e:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e51:	83 ec 08             	sub    $0x8,%esp
  800e54:	ff 75 f0             	pushl  -0x10(%ebp)
  800e57:	6a 00                	push   $0x0
  800e59:	e8 85 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e5e:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e61:	83 ec 08             	sub    $0x8,%esp
  800e64:	ff 75 f4             	pushl  -0xc(%ebp)
  800e67:	6a 00                	push   $0x0
  800e69:	e8 75 f3 ff ff       	call   8001e3 <sys_page_unmap>
  800e6e:	83 c4 10             	add    $0x10,%esp
  800e71:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e73:	89 d0                	mov    %edx,%eax
  800e75:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e78:	5b                   	pop    %ebx
  800e79:	5e                   	pop    %esi
  800e7a:	5d                   	pop    %ebp
  800e7b:	c3                   	ret    

00800e7c <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e7c:	55                   	push   %ebp
  800e7d:	89 e5                	mov    %esp,%ebp
  800e7f:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e82:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e85:	50                   	push   %eax
  800e86:	ff 75 08             	pushl  0x8(%ebp)
  800e89:	e8 37 f5 ff ff       	call   8003c5 <fd_lookup>
  800e8e:	83 c4 10             	add    $0x10,%esp
  800e91:	85 c0                	test   %eax,%eax
  800e93:	78 18                	js     800ead <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e95:	83 ec 0c             	sub    $0xc,%esp
  800e98:	ff 75 f4             	pushl  -0xc(%ebp)
  800e9b:	e8 bf f4 ff ff       	call   80035f <fd2data>
	return _pipeisclosed(fd, p);
  800ea0:	89 c2                	mov    %eax,%edx
  800ea2:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800ea5:	e8 21 fd ff ff       	call   800bcb <_pipeisclosed>
  800eaa:	83 c4 10             	add    $0x10,%esp
}
  800ead:	c9                   	leave  
  800eae:	c3                   	ret    

00800eaf <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eaf:	55                   	push   %ebp
  800eb0:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb2:	b8 00 00 00 00       	mov    $0x0,%eax
  800eb7:	5d                   	pop    %ebp
  800eb8:	c3                   	ret    

00800eb9 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800eb9:	55                   	push   %ebp
  800eba:	89 e5                	mov    %esp,%ebp
  800ebc:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ebf:	68 f6 1e 80 00       	push   $0x801ef6
  800ec4:	ff 75 0c             	pushl  0xc(%ebp)
  800ec7:	e8 0e 08 00 00       	call   8016da <strcpy>
	return 0;
}
  800ecc:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed1:	c9                   	leave  
  800ed2:	c3                   	ret    

00800ed3 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed3:	55                   	push   %ebp
  800ed4:	89 e5                	mov    %esp,%ebp
  800ed6:	57                   	push   %edi
  800ed7:	56                   	push   %esi
  800ed8:	53                   	push   %ebx
  800ed9:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800edf:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee4:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eea:	eb 2d                	jmp    800f19 <devcons_write+0x46>
		m = n - tot;
  800eec:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800eef:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ef1:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef4:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800ef9:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800efc:	83 ec 04             	sub    $0x4,%esp
  800eff:	53                   	push   %ebx
  800f00:	03 45 0c             	add    0xc(%ebp),%eax
  800f03:	50                   	push   %eax
  800f04:	57                   	push   %edi
  800f05:	e8 62 09 00 00       	call   80186c <memmove>
		sys_cputs(buf, m);
  800f0a:	83 c4 08             	add    $0x8,%esp
  800f0d:	53                   	push   %ebx
  800f0e:	57                   	push   %edi
  800f0f:	e8 8e f1 ff ff       	call   8000a2 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f14:	01 de                	add    %ebx,%esi
  800f16:	83 c4 10             	add    $0x10,%esp
  800f19:	89 f0                	mov    %esi,%eax
  800f1b:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f1e:	72 cc                	jb     800eec <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f20:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f23:	5b                   	pop    %ebx
  800f24:	5e                   	pop    %esi
  800f25:	5f                   	pop    %edi
  800f26:	5d                   	pop    %ebp
  800f27:	c3                   	ret    

00800f28 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f28:	55                   	push   %ebp
  800f29:	89 e5                	mov    %esp,%ebp
  800f2b:	83 ec 08             	sub    $0x8,%esp
  800f2e:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f33:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f37:	74 2a                	je     800f63 <devcons_read+0x3b>
  800f39:	eb 05                	jmp    800f40 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f3b:	e8 ff f1 ff ff       	call   80013f <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f40:	e8 7b f1 ff ff       	call   8000c0 <sys_cgetc>
  800f45:	85 c0                	test   %eax,%eax
  800f47:	74 f2                	je     800f3b <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f49:	85 c0                	test   %eax,%eax
  800f4b:	78 16                	js     800f63 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f4d:	83 f8 04             	cmp    $0x4,%eax
  800f50:	74 0c                	je     800f5e <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f52:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f55:	88 02                	mov    %al,(%edx)
	return 1;
  800f57:	b8 01 00 00 00       	mov    $0x1,%eax
  800f5c:	eb 05                	jmp    800f63 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f5e:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f63:	c9                   	leave  
  800f64:	c3                   	ret    

00800f65 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f65:	55                   	push   %ebp
  800f66:	89 e5                	mov    %esp,%ebp
  800f68:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f6b:	8b 45 08             	mov    0x8(%ebp),%eax
  800f6e:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f71:	6a 01                	push   $0x1
  800f73:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f76:	50                   	push   %eax
  800f77:	e8 26 f1 ff ff       	call   8000a2 <sys_cputs>
}
  800f7c:	83 c4 10             	add    $0x10,%esp
  800f7f:	c9                   	leave  
  800f80:	c3                   	ret    

00800f81 <getchar>:

int
getchar(void)
{
  800f81:	55                   	push   %ebp
  800f82:	89 e5                	mov    %esp,%ebp
  800f84:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f87:	6a 01                	push   $0x1
  800f89:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f8c:	50                   	push   %eax
  800f8d:	6a 00                	push   $0x0
  800f8f:	e8 97 f6 ff ff       	call   80062b <read>
	if (r < 0)
  800f94:	83 c4 10             	add    $0x10,%esp
  800f97:	85 c0                	test   %eax,%eax
  800f99:	78 0f                	js     800faa <getchar+0x29>
		return r;
	if (r < 1)
  800f9b:	85 c0                	test   %eax,%eax
  800f9d:	7e 06                	jle    800fa5 <getchar+0x24>
		return -E_EOF;
	return c;
  800f9f:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa3:	eb 05                	jmp    800faa <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fa5:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800faa:	c9                   	leave  
  800fab:	c3                   	ret    

00800fac <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fac:	55                   	push   %ebp
  800fad:	89 e5                	mov    %esp,%ebp
  800faf:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb2:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fb5:	50                   	push   %eax
  800fb6:	ff 75 08             	pushl  0x8(%ebp)
  800fb9:	e8 07 f4 ff ff       	call   8003c5 <fd_lookup>
  800fbe:	83 c4 10             	add    $0x10,%esp
  800fc1:	85 c0                	test   %eax,%eax
  800fc3:	78 11                	js     800fd6 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fc5:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fc8:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fce:	39 10                	cmp    %edx,(%eax)
  800fd0:	0f 94 c0             	sete   %al
  800fd3:	0f b6 c0             	movzbl %al,%eax
}
  800fd6:	c9                   	leave  
  800fd7:	c3                   	ret    

00800fd8 <opencons>:

int
opencons(void)
{
  800fd8:	55                   	push   %ebp
  800fd9:	89 e5                	mov    %esp,%ebp
  800fdb:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fde:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe1:	50                   	push   %eax
  800fe2:	e8 8f f3 ff ff       	call   800376 <fd_alloc>
  800fe7:	83 c4 10             	add    $0x10,%esp
		return r;
  800fea:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fec:	85 c0                	test   %eax,%eax
  800fee:	78 3e                	js     80102e <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff0:	83 ec 04             	sub    $0x4,%esp
  800ff3:	68 07 04 00 00       	push   $0x407
  800ff8:	ff 75 f4             	pushl  -0xc(%ebp)
  800ffb:	6a 00                	push   $0x0
  800ffd:	e8 5c f1 ff ff       	call   80015e <sys_page_alloc>
  801002:	83 c4 10             	add    $0x10,%esp
		return r;
  801005:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801007:	85 c0                	test   %eax,%eax
  801009:	78 23                	js     80102e <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  80100b:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801011:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801014:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801019:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801020:	83 ec 0c             	sub    $0xc,%esp
  801023:	50                   	push   %eax
  801024:	e8 26 f3 ff ff       	call   80034f <fd2num>
  801029:	89 c2                	mov    %eax,%edx
  80102b:	83 c4 10             	add    $0x10,%esp
}
  80102e:	89 d0                	mov    %edx,%eax
  801030:	c9                   	leave  
  801031:	c3                   	ret    

00801032 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801032:	55                   	push   %ebp
  801033:	89 e5                	mov    %esp,%ebp
  801035:	56                   	push   %esi
  801036:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801037:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80103a:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801040:	e8 db f0 ff ff       	call   800120 <sys_getenvid>
  801045:	83 ec 0c             	sub    $0xc,%esp
  801048:	ff 75 0c             	pushl  0xc(%ebp)
  80104b:	ff 75 08             	pushl  0x8(%ebp)
  80104e:	56                   	push   %esi
  80104f:	50                   	push   %eax
  801050:	68 04 1f 80 00       	push   $0x801f04
  801055:	e8 b1 00 00 00       	call   80110b <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80105a:	83 c4 18             	add    $0x18,%esp
  80105d:	53                   	push   %ebx
  80105e:	ff 75 10             	pushl  0x10(%ebp)
  801061:	e8 54 00 00 00       	call   8010ba <vcprintf>
	cprintf("\n");
  801066:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  80106d:	e8 99 00 00 00       	call   80110b <cprintf>
  801072:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801075:	cc                   	int3   
  801076:	eb fd                	jmp    801075 <_panic+0x43>

00801078 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801078:	55                   	push   %ebp
  801079:	89 e5                	mov    %esp,%ebp
  80107b:	53                   	push   %ebx
  80107c:	83 ec 04             	sub    $0x4,%esp
  80107f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801082:	8b 13                	mov    (%ebx),%edx
  801084:	8d 42 01             	lea    0x1(%edx),%eax
  801087:	89 03                	mov    %eax,(%ebx)
  801089:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80108c:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801090:	3d ff 00 00 00       	cmp    $0xff,%eax
  801095:	75 1a                	jne    8010b1 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  801097:	83 ec 08             	sub    $0x8,%esp
  80109a:	68 ff 00 00 00       	push   $0xff
  80109f:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a2:	50                   	push   %eax
  8010a3:	e8 fa ef ff ff       	call   8000a2 <sys_cputs>
		b->idx = 0;
  8010a8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ae:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b1:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010b8:	c9                   	leave  
  8010b9:	c3                   	ret    

008010ba <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010ba:	55                   	push   %ebp
  8010bb:	89 e5                	mov    %esp,%ebp
  8010bd:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8010c3:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010ca:	00 00 00 
	b.cnt = 0;
  8010cd:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d4:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010d7:	ff 75 0c             	pushl  0xc(%ebp)
  8010da:	ff 75 08             	pushl  0x8(%ebp)
  8010dd:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e3:	50                   	push   %eax
  8010e4:	68 78 10 80 00       	push   $0x801078
  8010e9:	e8 54 01 00 00       	call   801242 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010ee:	83 c4 08             	add    $0x8,%esp
  8010f1:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010f7:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8010fd:	50                   	push   %eax
  8010fe:	e8 9f ef ff ff       	call   8000a2 <sys_cputs>

	return b.cnt;
}
  801103:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801109:	c9                   	leave  
  80110a:	c3                   	ret    

0080110b <cprintf>:

int
cprintf(const char *fmt, ...)
{
  80110b:	55                   	push   %ebp
  80110c:	89 e5                	mov    %esp,%ebp
  80110e:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801111:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801114:	50                   	push   %eax
  801115:	ff 75 08             	pushl  0x8(%ebp)
  801118:	e8 9d ff ff ff       	call   8010ba <vcprintf>
	va_end(ap);

	return cnt;
}
  80111d:	c9                   	leave  
  80111e:	c3                   	ret    

0080111f <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80111f:	55                   	push   %ebp
  801120:	89 e5                	mov    %esp,%ebp
  801122:	57                   	push   %edi
  801123:	56                   	push   %esi
  801124:	53                   	push   %ebx
  801125:	83 ec 1c             	sub    $0x1c,%esp
  801128:	89 c7                	mov    %eax,%edi
  80112a:	89 d6                	mov    %edx,%esi
  80112c:	8b 45 08             	mov    0x8(%ebp),%eax
  80112f:	8b 55 0c             	mov    0xc(%ebp),%edx
  801132:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801135:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801138:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80113b:	bb 00 00 00 00       	mov    $0x0,%ebx
  801140:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801143:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801146:	39 d3                	cmp    %edx,%ebx
  801148:	72 05                	jb     80114f <printnum+0x30>
  80114a:	39 45 10             	cmp    %eax,0x10(%ebp)
  80114d:	77 45                	ja     801194 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80114f:	83 ec 0c             	sub    $0xc,%esp
  801152:	ff 75 18             	pushl  0x18(%ebp)
  801155:	8b 45 14             	mov    0x14(%ebp),%eax
  801158:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80115b:	53                   	push   %ebx
  80115c:	ff 75 10             	pushl  0x10(%ebp)
  80115f:	83 ec 08             	sub    $0x8,%esp
  801162:	ff 75 e4             	pushl  -0x1c(%ebp)
  801165:	ff 75 e0             	pushl  -0x20(%ebp)
  801168:	ff 75 dc             	pushl  -0x24(%ebp)
  80116b:	ff 75 d8             	pushl  -0x28(%ebp)
  80116e:	e8 cd 09 00 00       	call   801b40 <__udivdi3>
  801173:	83 c4 18             	add    $0x18,%esp
  801176:	52                   	push   %edx
  801177:	50                   	push   %eax
  801178:	89 f2                	mov    %esi,%edx
  80117a:	89 f8                	mov    %edi,%eax
  80117c:	e8 9e ff ff ff       	call   80111f <printnum>
  801181:	83 c4 20             	add    $0x20,%esp
  801184:	eb 18                	jmp    80119e <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801186:	83 ec 08             	sub    $0x8,%esp
  801189:	56                   	push   %esi
  80118a:	ff 75 18             	pushl  0x18(%ebp)
  80118d:	ff d7                	call   *%edi
  80118f:	83 c4 10             	add    $0x10,%esp
  801192:	eb 03                	jmp    801197 <printnum+0x78>
  801194:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  801197:	83 eb 01             	sub    $0x1,%ebx
  80119a:	85 db                	test   %ebx,%ebx
  80119c:	7f e8                	jg     801186 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80119e:	83 ec 08             	sub    $0x8,%esp
  8011a1:	56                   	push   %esi
  8011a2:	83 ec 04             	sub    $0x4,%esp
  8011a5:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011a8:	ff 75 e0             	pushl  -0x20(%ebp)
  8011ab:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ae:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b1:	e8 ba 0a 00 00       	call   801c70 <__umoddi3>
  8011b6:	83 c4 14             	add    $0x14,%esp
  8011b9:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  8011c0:	50                   	push   %eax
  8011c1:	ff d7                	call   *%edi
}
  8011c3:	83 c4 10             	add    $0x10,%esp
  8011c6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011c9:	5b                   	pop    %ebx
  8011ca:	5e                   	pop    %esi
  8011cb:	5f                   	pop    %edi
  8011cc:	5d                   	pop    %ebp
  8011cd:	c3                   	ret    

008011ce <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011ce:	55                   	push   %ebp
  8011cf:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011d1:	83 fa 01             	cmp    $0x1,%edx
  8011d4:	7e 0e                	jle    8011e4 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011d6:	8b 10                	mov    (%eax),%edx
  8011d8:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011db:	89 08                	mov    %ecx,(%eax)
  8011dd:	8b 02                	mov    (%edx),%eax
  8011df:	8b 52 04             	mov    0x4(%edx),%edx
  8011e2:	eb 22                	jmp    801206 <getuint+0x38>
	else if (lflag)
  8011e4:	85 d2                	test   %edx,%edx
  8011e6:	74 10                	je     8011f8 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011e8:	8b 10                	mov    (%eax),%edx
  8011ea:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011ed:	89 08                	mov    %ecx,(%eax)
  8011ef:	8b 02                	mov    (%edx),%eax
  8011f1:	ba 00 00 00 00       	mov    $0x0,%edx
  8011f6:	eb 0e                	jmp    801206 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011f8:	8b 10                	mov    (%eax),%edx
  8011fa:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011fd:	89 08                	mov    %ecx,(%eax)
  8011ff:	8b 02                	mov    (%edx),%eax
  801201:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801206:	5d                   	pop    %ebp
  801207:	c3                   	ret    

00801208 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801208:	55                   	push   %ebp
  801209:	89 e5                	mov    %esp,%ebp
  80120b:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80120e:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801212:	8b 10                	mov    (%eax),%edx
  801214:	3b 50 04             	cmp    0x4(%eax),%edx
  801217:	73 0a                	jae    801223 <sprintputch+0x1b>
		*b->buf++ = ch;
  801219:	8d 4a 01             	lea    0x1(%edx),%ecx
  80121c:	89 08                	mov    %ecx,(%eax)
  80121e:	8b 45 08             	mov    0x8(%ebp),%eax
  801221:	88 02                	mov    %al,(%edx)
}
  801223:	5d                   	pop    %ebp
  801224:	c3                   	ret    

00801225 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801225:	55                   	push   %ebp
  801226:	89 e5                	mov    %esp,%ebp
  801228:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80122b:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80122e:	50                   	push   %eax
  80122f:	ff 75 10             	pushl  0x10(%ebp)
  801232:	ff 75 0c             	pushl  0xc(%ebp)
  801235:	ff 75 08             	pushl  0x8(%ebp)
  801238:	e8 05 00 00 00       	call   801242 <vprintfmt>
	va_end(ap);
}
  80123d:	83 c4 10             	add    $0x10,%esp
  801240:	c9                   	leave  
  801241:	c3                   	ret    

00801242 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801242:	55                   	push   %ebp
  801243:	89 e5                	mov    %esp,%ebp
  801245:	57                   	push   %edi
  801246:	56                   	push   %esi
  801247:	53                   	push   %ebx
  801248:	83 ec 2c             	sub    $0x2c,%esp
  80124b:	8b 75 08             	mov    0x8(%ebp),%esi
  80124e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801251:	8b 7d 10             	mov    0x10(%ebp),%edi
  801254:	eb 12                	jmp    801268 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801256:	85 c0                	test   %eax,%eax
  801258:	0f 84 d3 03 00 00    	je     801631 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80125e:	83 ec 08             	sub    $0x8,%esp
  801261:	53                   	push   %ebx
  801262:	50                   	push   %eax
  801263:	ff d6                	call   *%esi
  801265:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801268:	83 c7 01             	add    $0x1,%edi
  80126b:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80126f:	83 f8 25             	cmp    $0x25,%eax
  801272:	75 e2                	jne    801256 <vprintfmt+0x14>
  801274:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801278:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80127f:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801286:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80128d:	ba 00 00 00 00       	mov    $0x0,%edx
  801292:	eb 07                	jmp    80129b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801294:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  801297:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80129b:	8d 47 01             	lea    0x1(%edi),%eax
  80129e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012a1:	0f b6 07             	movzbl (%edi),%eax
  8012a4:	0f b6 c8             	movzbl %al,%ecx
  8012a7:	83 e8 23             	sub    $0x23,%eax
  8012aa:	3c 55                	cmp    $0x55,%al
  8012ac:	0f 87 64 03 00 00    	ja     801616 <vprintfmt+0x3d4>
  8012b2:	0f b6 c0             	movzbl %al,%eax
  8012b5:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  8012bc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012bf:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012c3:	eb d6                	jmp    80129b <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012c5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012c8:	b8 00 00 00 00       	mov    $0x0,%eax
  8012cd:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012d0:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012d3:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012d7:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012da:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012dd:	83 fa 09             	cmp    $0x9,%edx
  8012e0:	77 39                	ja     80131b <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012e2:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012e5:	eb e9                	jmp    8012d0 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012e7:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ea:	8d 48 04             	lea    0x4(%eax),%ecx
  8012ed:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012f0:	8b 00                	mov    (%eax),%eax
  8012f2:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012f5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012f8:	eb 27                	jmp    801321 <vprintfmt+0xdf>
  8012fa:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8012fd:	85 c0                	test   %eax,%eax
  8012ff:	b9 00 00 00 00       	mov    $0x0,%ecx
  801304:	0f 49 c8             	cmovns %eax,%ecx
  801307:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80130d:	eb 8c                	jmp    80129b <vprintfmt+0x59>
  80130f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801312:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801319:	eb 80                	jmp    80129b <vprintfmt+0x59>
  80131b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80131e:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  801321:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801325:	0f 89 70 ff ff ff    	jns    80129b <vprintfmt+0x59>
				width = precision, precision = -1;
  80132b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80132e:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801331:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801338:	e9 5e ff ff ff       	jmp    80129b <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80133d:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801340:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801343:	e9 53 ff ff ff       	jmp    80129b <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801348:	8b 45 14             	mov    0x14(%ebp),%eax
  80134b:	8d 50 04             	lea    0x4(%eax),%edx
  80134e:	89 55 14             	mov    %edx,0x14(%ebp)
  801351:	83 ec 08             	sub    $0x8,%esp
  801354:	53                   	push   %ebx
  801355:	ff 30                	pushl  (%eax)
  801357:	ff d6                	call   *%esi
			break;
  801359:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80135c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80135f:	e9 04 ff ff ff       	jmp    801268 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801364:	8b 45 14             	mov    0x14(%ebp),%eax
  801367:	8d 50 04             	lea    0x4(%eax),%edx
  80136a:	89 55 14             	mov    %edx,0x14(%ebp)
  80136d:	8b 00                	mov    (%eax),%eax
  80136f:	99                   	cltd   
  801370:	31 d0                	xor    %edx,%eax
  801372:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801374:	83 f8 0f             	cmp    $0xf,%eax
  801377:	7f 0b                	jg     801384 <vprintfmt+0x142>
  801379:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  801380:	85 d2                	test   %edx,%edx
  801382:	75 18                	jne    80139c <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801384:	50                   	push   %eax
  801385:	68 3f 1f 80 00       	push   $0x801f3f
  80138a:	53                   	push   %ebx
  80138b:	56                   	push   %esi
  80138c:	e8 94 fe ff ff       	call   801225 <printfmt>
  801391:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801394:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  801397:	e9 cc fe ff ff       	jmp    801268 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80139c:	52                   	push   %edx
  80139d:	68 bd 1e 80 00       	push   $0x801ebd
  8013a2:	53                   	push   %ebx
  8013a3:	56                   	push   %esi
  8013a4:	e8 7c fe ff ff       	call   801225 <printfmt>
  8013a9:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013ac:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013af:	e9 b4 fe ff ff       	jmp    801268 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013b4:	8b 45 14             	mov    0x14(%ebp),%eax
  8013b7:	8d 50 04             	lea    0x4(%eax),%edx
  8013ba:	89 55 14             	mov    %edx,0x14(%ebp)
  8013bd:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013bf:	85 ff                	test   %edi,%edi
  8013c1:	b8 38 1f 80 00       	mov    $0x801f38,%eax
  8013c6:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013c9:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013cd:	0f 8e 94 00 00 00    	jle    801467 <vprintfmt+0x225>
  8013d3:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013d7:	0f 84 98 00 00 00    	je     801475 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013dd:	83 ec 08             	sub    $0x8,%esp
  8013e0:	ff 75 c8             	pushl  -0x38(%ebp)
  8013e3:	57                   	push   %edi
  8013e4:	e8 d0 02 00 00       	call   8016b9 <strnlen>
  8013e9:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013ec:	29 c1                	sub    %eax,%ecx
  8013ee:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8013f1:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013f4:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013f8:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8013fb:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8013fe:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801400:	eb 0f                	jmp    801411 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801402:	83 ec 08             	sub    $0x8,%esp
  801405:	53                   	push   %ebx
  801406:	ff 75 e0             	pushl  -0x20(%ebp)
  801409:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80140b:	83 ef 01             	sub    $0x1,%edi
  80140e:	83 c4 10             	add    $0x10,%esp
  801411:	85 ff                	test   %edi,%edi
  801413:	7f ed                	jg     801402 <vprintfmt+0x1c0>
  801415:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801418:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  80141b:	85 c9                	test   %ecx,%ecx
  80141d:	b8 00 00 00 00       	mov    $0x0,%eax
  801422:	0f 49 c1             	cmovns %ecx,%eax
  801425:	29 c1                	sub    %eax,%ecx
  801427:	89 75 08             	mov    %esi,0x8(%ebp)
  80142a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80142d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801430:	89 cb                	mov    %ecx,%ebx
  801432:	eb 4d                	jmp    801481 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801434:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801438:	74 1b                	je     801455 <vprintfmt+0x213>
  80143a:	0f be c0             	movsbl %al,%eax
  80143d:	83 e8 20             	sub    $0x20,%eax
  801440:	83 f8 5e             	cmp    $0x5e,%eax
  801443:	76 10                	jbe    801455 <vprintfmt+0x213>
					putch('?', putdat);
  801445:	83 ec 08             	sub    $0x8,%esp
  801448:	ff 75 0c             	pushl  0xc(%ebp)
  80144b:	6a 3f                	push   $0x3f
  80144d:	ff 55 08             	call   *0x8(%ebp)
  801450:	83 c4 10             	add    $0x10,%esp
  801453:	eb 0d                	jmp    801462 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801455:	83 ec 08             	sub    $0x8,%esp
  801458:	ff 75 0c             	pushl  0xc(%ebp)
  80145b:	52                   	push   %edx
  80145c:	ff 55 08             	call   *0x8(%ebp)
  80145f:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801462:	83 eb 01             	sub    $0x1,%ebx
  801465:	eb 1a                	jmp    801481 <vprintfmt+0x23f>
  801467:	89 75 08             	mov    %esi,0x8(%ebp)
  80146a:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80146d:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801470:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801473:	eb 0c                	jmp    801481 <vprintfmt+0x23f>
  801475:	89 75 08             	mov    %esi,0x8(%ebp)
  801478:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80147b:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147e:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801481:	83 c7 01             	add    $0x1,%edi
  801484:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801488:	0f be d0             	movsbl %al,%edx
  80148b:	85 d2                	test   %edx,%edx
  80148d:	74 23                	je     8014b2 <vprintfmt+0x270>
  80148f:	85 f6                	test   %esi,%esi
  801491:	78 a1                	js     801434 <vprintfmt+0x1f2>
  801493:	83 ee 01             	sub    $0x1,%esi
  801496:	79 9c                	jns    801434 <vprintfmt+0x1f2>
  801498:	89 df                	mov    %ebx,%edi
  80149a:	8b 75 08             	mov    0x8(%ebp),%esi
  80149d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a0:	eb 18                	jmp    8014ba <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014a2:	83 ec 08             	sub    $0x8,%esp
  8014a5:	53                   	push   %ebx
  8014a6:	6a 20                	push   $0x20
  8014a8:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014aa:	83 ef 01             	sub    $0x1,%edi
  8014ad:	83 c4 10             	add    $0x10,%esp
  8014b0:	eb 08                	jmp    8014ba <vprintfmt+0x278>
  8014b2:	89 df                	mov    %ebx,%edi
  8014b4:	8b 75 08             	mov    0x8(%ebp),%esi
  8014b7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014ba:	85 ff                	test   %edi,%edi
  8014bc:	7f e4                	jg     8014a2 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014be:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014c1:	e9 a2 fd ff ff       	jmp    801268 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014c6:	83 fa 01             	cmp    $0x1,%edx
  8014c9:	7e 16                	jle    8014e1 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014cb:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ce:	8d 50 08             	lea    0x8(%eax),%edx
  8014d1:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d4:	8b 50 04             	mov    0x4(%eax),%edx
  8014d7:	8b 00                	mov    (%eax),%eax
  8014d9:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8014dc:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8014df:	eb 32                	jmp    801513 <vprintfmt+0x2d1>
	else if (lflag)
  8014e1:	85 d2                	test   %edx,%edx
  8014e3:	74 18                	je     8014fd <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014e5:	8b 45 14             	mov    0x14(%ebp),%eax
  8014e8:	8d 50 04             	lea    0x4(%eax),%edx
  8014eb:	89 55 14             	mov    %edx,0x14(%ebp)
  8014ee:	8b 00                	mov    (%eax),%eax
  8014f0:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8014f3:	89 c1                	mov    %eax,%ecx
  8014f5:	c1 f9 1f             	sar    $0x1f,%ecx
  8014f8:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8014fb:	eb 16                	jmp    801513 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8014fd:	8b 45 14             	mov    0x14(%ebp),%eax
  801500:	8d 50 04             	lea    0x4(%eax),%edx
  801503:	89 55 14             	mov    %edx,0x14(%ebp)
  801506:	8b 00                	mov    (%eax),%eax
  801508:	89 45 c8             	mov    %eax,-0x38(%ebp)
  80150b:	89 c1                	mov    %eax,%ecx
  80150d:	c1 f9 1f             	sar    $0x1f,%ecx
  801510:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801513:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801516:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801519:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80151c:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80151f:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801524:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801528:	0f 89 b0 00 00 00    	jns    8015de <vprintfmt+0x39c>
				putch('-', putdat);
  80152e:	83 ec 08             	sub    $0x8,%esp
  801531:	53                   	push   %ebx
  801532:	6a 2d                	push   $0x2d
  801534:	ff d6                	call   *%esi
				num = -(long long) num;
  801536:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801539:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80153c:	f7 d8                	neg    %eax
  80153e:	83 d2 00             	adc    $0x0,%edx
  801541:	f7 da                	neg    %edx
  801543:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801546:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801549:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80154c:	b8 0a 00 00 00       	mov    $0xa,%eax
  801551:	e9 88 00 00 00       	jmp    8015de <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801556:	8d 45 14             	lea    0x14(%ebp),%eax
  801559:	e8 70 fc ff ff       	call   8011ce <getuint>
  80155e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801561:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  801564:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801569:	eb 73                	jmp    8015de <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80156b:	8d 45 14             	lea    0x14(%ebp),%eax
  80156e:	e8 5b fc ff ff       	call   8011ce <getuint>
  801573:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801576:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  801579:	83 ec 08             	sub    $0x8,%esp
  80157c:	53                   	push   %ebx
  80157d:	6a 58                	push   $0x58
  80157f:	ff d6                	call   *%esi
			putch('X', putdat);
  801581:	83 c4 08             	add    $0x8,%esp
  801584:	53                   	push   %ebx
  801585:	6a 58                	push   $0x58
  801587:	ff d6                	call   *%esi
			putch('X', putdat);
  801589:	83 c4 08             	add    $0x8,%esp
  80158c:	53                   	push   %ebx
  80158d:	6a 58                	push   $0x58
  80158f:	ff d6                	call   *%esi
			goto number;
  801591:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  801594:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  801599:	eb 43                	jmp    8015de <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80159b:	83 ec 08             	sub    $0x8,%esp
  80159e:	53                   	push   %ebx
  80159f:	6a 30                	push   $0x30
  8015a1:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a3:	83 c4 08             	add    $0x8,%esp
  8015a6:	53                   	push   %ebx
  8015a7:	6a 78                	push   $0x78
  8015a9:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015ab:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ae:	8d 50 04             	lea    0x4(%eax),%edx
  8015b1:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015b4:	8b 00                	mov    (%eax),%eax
  8015b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8015bb:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015be:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c1:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015c4:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015c9:	eb 13                	jmp    8015de <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015cb:	8d 45 14             	lea    0x14(%ebp),%eax
  8015ce:	e8 fb fb ff ff       	call   8011ce <getuint>
  8015d3:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015d6:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8015d9:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015de:	83 ec 0c             	sub    $0xc,%esp
  8015e1:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8015e5:	52                   	push   %edx
  8015e6:	ff 75 e0             	pushl  -0x20(%ebp)
  8015e9:	50                   	push   %eax
  8015ea:	ff 75 dc             	pushl  -0x24(%ebp)
  8015ed:	ff 75 d8             	pushl  -0x28(%ebp)
  8015f0:	89 da                	mov    %ebx,%edx
  8015f2:	89 f0                	mov    %esi,%eax
  8015f4:	e8 26 fb ff ff       	call   80111f <printnum>
			break;
  8015f9:	83 c4 20             	add    $0x20,%esp
  8015fc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8015ff:	e9 64 fc ff ff       	jmp    801268 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801604:	83 ec 08             	sub    $0x8,%esp
  801607:	53                   	push   %ebx
  801608:	51                   	push   %ecx
  801609:	ff d6                	call   *%esi
			break;
  80160b:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80160e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801611:	e9 52 fc ff ff       	jmp    801268 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801616:	83 ec 08             	sub    $0x8,%esp
  801619:	53                   	push   %ebx
  80161a:	6a 25                	push   $0x25
  80161c:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80161e:	83 c4 10             	add    $0x10,%esp
  801621:	eb 03                	jmp    801626 <vprintfmt+0x3e4>
  801623:	83 ef 01             	sub    $0x1,%edi
  801626:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80162a:	75 f7                	jne    801623 <vprintfmt+0x3e1>
  80162c:	e9 37 fc ff ff       	jmp    801268 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801631:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801634:	5b                   	pop    %ebx
  801635:	5e                   	pop    %esi
  801636:	5f                   	pop    %edi
  801637:	5d                   	pop    %ebp
  801638:	c3                   	ret    

00801639 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801639:	55                   	push   %ebp
  80163a:	89 e5                	mov    %esp,%ebp
  80163c:	83 ec 18             	sub    $0x18,%esp
  80163f:	8b 45 08             	mov    0x8(%ebp),%eax
  801642:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801645:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801648:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80164c:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80164f:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801656:	85 c0                	test   %eax,%eax
  801658:	74 26                	je     801680 <vsnprintf+0x47>
  80165a:	85 d2                	test   %edx,%edx
  80165c:	7e 22                	jle    801680 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80165e:	ff 75 14             	pushl  0x14(%ebp)
  801661:	ff 75 10             	pushl  0x10(%ebp)
  801664:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801667:	50                   	push   %eax
  801668:	68 08 12 80 00       	push   $0x801208
  80166d:	e8 d0 fb ff ff       	call   801242 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801672:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801675:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801678:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80167b:	83 c4 10             	add    $0x10,%esp
  80167e:	eb 05                	jmp    801685 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801680:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801685:	c9                   	leave  
  801686:	c3                   	ret    

00801687 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801687:	55                   	push   %ebp
  801688:	89 e5                	mov    %esp,%ebp
  80168a:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80168d:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801690:	50                   	push   %eax
  801691:	ff 75 10             	pushl  0x10(%ebp)
  801694:	ff 75 0c             	pushl  0xc(%ebp)
  801697:	ff 75 08             	pushl  0x8(%ebp)
  80169a:	e8 9a ff ff ff       	call   801639 <vsnprintf>
	va_end(ap);

	return rc;
}
  80169f:	c9                   	leave  
  8016a0:	c3                   	ret    

008016a1 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016a1:	55                   	push   %ebp
  8016a2:	89 e5                	mov    %esp,%ebp
  8016a4:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8016ac:	eb 03                	jmp    8016b1 <strlen+0x10>
		n++;
  8016ae:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b1:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016b5:	75 f7                	jne    8016ae <strlen+0xd>
		n++;
	return n;
}
  8016b7:	5d                   	pop    %ebp
  8016b8:	c3                   	ret    

008016b9 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016b9:	55                   	push   %ebp
  8016ba:	89 e5                	mov    %esp,%ebp
  8016bc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016bf:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8016c7:	eb 03                	jmp    8016cc <strnlen+0x13>
		n++;
  8016c9:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016cc:	39 c2                	cmp    %eax,%edx
  8016ce:	74 08                	je     8016d8 <strnlen+0x1f>
  8016d0:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016d4:	75 f3                	jne    8016c9 <strnlen+0x10>
  8016d6:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016d8:	5d                   	pop    %ebp
  8016d9:	c3                   	ret    

008016da <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016da:	55                   	push   %ebp
  8016db:	89 e5                	mov    %esp,%ebp
  8016dd:	53                   	push   %ebx
  8016de:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e4:	89 c2                	mov    %eax,%edx
  8016e6:	83 c2 01             	add    $0x1,%edx
  8016e9:	83 c1 01             	add    $0x1,%ecx
  8016ec:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016f0:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016f3:	84 db                	test   %bl,%bl
  8016f5:	75 ef                	jne    8016e6 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016f7:	5b                   	pop    %ebx
  8016f8:	5d                   	pop    %ebp
  8016f9:	c3                   	ret    

008016fa <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016fa:	55                   	push   %ebp
  8016fb:	89 e5                	mov    %esp,%ebp
  8016fd:	53                   	push   %ebx
  8016fe:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801701:	53                   	push   %ebx
  801702:	e8 9a ff ff ff       	call   8016a1 <strlen>
  801707:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80170a:	ff 75 0c             	pushl  0xc(%ebp)
  80170d:	01 d8                	add    %ebx,%eax
  80170f:	50                   	push   %eax
  801710:	e8 c5 ff ff ff       	call   8016da <strcpy>
	return dst;
}
  801715:	89 d8                	mov    %ebx,%eax
  801717:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171a:	c9                   	leave  
  80171b:	c3                   	ret    

0080171c <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  80171c:	55                   	push   %ebp
  80171d:	89 e5                	mov    %esp,%ebp
  80171f:	56                   	push   %esi
  801720:	53                   	push   %ebx
  801721:	8b 75 08             	mov    0x8(%ebp),%esi
  801724:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801727:	89 f3                	mov    %esi,%ebx
  801729:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80172c:	89 f2                	mov    %esi,%edx
  80172e:	eb 0f                	jmp    80173f <strncpy+0x23>
		*dst++ = *src;
  801730:	83 c2 01             	add    $0x1,%edx
  801733:	0f b6 01             	movzbl (%ecx),%eax
  801736:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801739:	80 39 01             	cmpb   $0x1,(%ecx)
  80173c:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80173f:	39 da                	cmp    %ebx,%edx
  801741:	75 ed                	jne    801730 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801743:	89 f0                	mov    %esi,%eax
  801745:	5b                   	pop    %ebx
  801746:	5e                   	pop    %esi
  801747:	5d                   	pop    %ebp
  801748:	c3                   	ret    

00801749 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801749:	55                   	push   %ebp
  80174a:	89 e5                	mov    %esp,%ebp
  80174c:	56                   	push   %esi
  80174d:	53                   	push   %ebx
  80174e:	8b 75 08             	mov    0x8(%ebp),%esi
  801751:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801754:	8b 55 10             	mov    0x10(%ebp),%edx
  801757:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801759:	85 d2                	test   %edx,%edx
  80175b:	74 21                	je     80177e <strlcpy+0x35>
  80175d:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801761:	89 f2                	mov    %esi,%edx
  801763:	eb 09                	jmp    80176e <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801765:	83 c2 01             	add    $0x1,%edx
  801768:	83 c1 01             	add    $0x1,%ecx
  80176b:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80176e:	39 c2                	cmp    %eax,%edx
  801770:	74 09                	je     80177b <strlcpy+0x32>
  801772:	0f b6 19             	movzbl (%ecx),%ebx
  801775:	84 db                	test   %bl,%bl
  801777:	75 ec                	jne    801765 <strlcpy+0x1c>
  801779:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  80177b:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80177e:	29 f0                	sub    %esi,%eax
}
  801780:	5b                   	pop    %ebx
  801781:	5e                   	pop    %esi
  801782:	5d                   	pop    %ebp
  801783:	c3                   	ret    

00801784 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801784:	55                   	push   %ebp
  801785:	89 e5                	mov    %esp,%ebp
  801787:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178a:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  80178d:	eb 06                	jmp    801795 <strcmp+0x11>
		p++, q++;
  80178f:	83 c1 01             	add    $0x1,%ecx
  801792:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  801795:	0f b6 01             	movzbl (%ecx),%eax
  801798:	84 c0                	test   %al,%al
  80179a:	74 04                	je     8017a0 <strcmp+0x1c>
  80179c:	3a 02                	cmp    (%edx),%al
  80179e:	74 ef                	je     80178f <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a0:	0f b6 c0             	movzbl %al,%eax
  8017a3:	0f b6 12             	movzbl (%edx),%edx
  8017a6:	29 d0                	sub    %edx,%eax
}
  8017a8:	5d                   	pop    %ebp
  8017a9:	c3                   	ret    

008017aa <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017aa:	55                   	push   %ebp
  8017ab:	89 e5                	mov    %esp,%ebp
  8017ad:	53                   	push   %ebx
  8017ae:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b1:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b4:	89 c3                	mov    %eax,%ebx
  8017b6:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017b9:	eb 06                	jmp    8017c1 <strncmp+0x17>
		n--, p++, q++;
  8017bb:	83 c0 01             	add    $0x1,%eax
  8017be:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017c1:	39 d8                	cmp    %ebx,%eax
  8017c3:	74 15                	je     8017da <strncmp+0x30>
  8017c5:	0f b6 08             	movzbl (%eax),%ecx
  8017c8:	84 c9                	test   %cl,%cl
  8017ca:	74 04                	je     8017d0 <strncmp+0x26>
  8017cc:	3a 0a                	cmp    (%edx),%cl
  8017ce:	74 eb                	je     8017bb <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d0:	0f b6 00             	movzbl (%eax),%eax
  8017d3:	0f b6 12             	movzbl (%edx),%edx
  8017d6:	29 d0                	sub    %edx,%eax
  8017d8:	eb 05                	jmp    8017df <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017da:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017df:	5b                   	pop    %ebx
  8017e0:	5d                   	pop    %ebp
  8017e1:	c3                   	ret    

008017e2 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e2:	55                   	push   %ebp
  8017e3:	89 e5                	mov    %esp,%ebp
  8017e5:	8b 45 08             	mov    0x8(%ebp),%eax
  8017e8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017ec:	eb 07                	jmp    8017f5 <strchr+0x13>
		if (*s == c)
  8017ee:	38 ca                	cmp    %cl,%dl
  8017f0:	74 0f                	je     801801 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017f2:	83 c0 01             	add    $0x1,%eax
  8017f5:	0f b6 10             	movzbl (%eax),%edx
  8017f8:	84 d2                	test   %dl,%dl
  8017fa:	75 f2                	jne    8017ee <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  8017fc:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801801:	5d                   	pop    %ebp
  801802:	c3                   	ret    

00801803 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801803:	55                   	push   %ebp
  801804:	89 e5                	mov    %esp,%ebp
  801806:	8b 45 08             	mov    0x8(%ebp),%eax
  801809:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  80180d:	eb 03                	jmp    801812 <strfind+0xf>
  80180f:	83 c0 01             	add    $0x1,%eax
  801812:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801815:	38 ca                	cmp    %cl,%dl
  801817:	74 04                	je     80181d <strfind+0x1a>
  801819:	84 d2                	test   %dl,%dl
  80181b:	75 f2                	jne    80180f <strfind+0xc>
			break;
	return (char *) s;
}
  80181d:	5d                   	pop    %ebp
  80181e:	c3                   	ret    

0080181f <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80181f:	55                   	push   %ebp
  801820:	89 e5                	mov    %esp,%ebp
  801822:	57                   	push   %edi
  801823:	56                   	push   %esi
  801824:	53                   	push   %ebx
  801825:	8b 7d 08             	mov    0x8(%ebp),%edi
  801828:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  80182b:	85 c9                	test   %ecx,%ecx
  80182d:	74 36                	je     801865 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80182f:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801835:	75 28                	jne    80185f <memset+0x40>
  801837:	f6 c1 03             	test   $0x3,%cl
  80183a:	75 23                	jne    80185f <memset+0x40>
		c &= 0xFF;
  80183c:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801840:	89 d3                	mov    %edx,%ebx
  801842:	c1 e3 08             	shl    $0x8,%ebx
  801845:	89 d6                	mov    %edx,%esi
  801847:	c1 e6 18             	shl    $0x18,%esi
  80184a:	89 d0                	mov    %edx,%eax
  80184c:	c1 e0 10             	shl    $0x10,%eax
  80184f:	09 f0                	or     %esi,%eax
  801851:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801853:	89 d8                	mov    %ebx,%eax
  801855:	09 d0                	or     %edx,%eax
  801857:	c1 e9 02             	shr    $0x2,%ecx
  80185a:	fc                   	cld    
  80185b:	f3 ab                	rep stos %eax,%es:(%edi)
  80185d:	eb 06                	jmp    801865 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80185f:	8b 45 0c             	mov    0xc(%ebp),%eax
  801862:	fc                   	cld    
  801863:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801865:	89 f8                	mov    %edi,%eax
  801867:	5b                   	pop    %ebx
  801868:	5e                   	pop    %esi
  801869:	5f                   	pop    %edi
  80186a:	5d                   	pop    %ebp
  80186b:	c3                   	ret    

0080186c <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  80186c:	55                   	push   %ebp
  80186d:	89 e5                	mov    %esp,%ebp
  80186f:	57                   	push   %edi
  801870:	56                   	push   %esi
  801871:	8b 45 08             	mov    0x8(%ebp),%eax
  801874:	8b 75 0c             	mov    0xc(%ebp),%esi
  801877:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80187a:	39 c6                	cmp    %eax,%esi
  80187c:	73 35                	jae    8018b3 <memmove+0x47>
  80187e:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801881:	39 d0                	cmp    %edx,%eax
  801883:	73 2e                	jae    8018b3 <memmove+0x47>
		s += n;
		d += n;
  801885:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801888:	89 d6                	mov    %edx,%esi
  80188a:	09 fe                	or     %edi,%esi
  80188c:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801892:	75 13                	jne    8018a7 <memmove+0x3b>
  801894:	f6 c1 03             	test   $0x3,%cl
  801897:	75 0e                	jne    8018a7 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  801899:	83 ef 04             	sub    $0x4,%edi
  80189c:	8d 72 fc             	lea    -0x4(%edx),%esi
  80189f:	c1 e9 02             	shr    $0x2,%ecx
  8018a2:	fd                   	std    
  8018a3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018a5:	eb 09                	jmp    8018b0 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018a7:	83 ef 01             	sub    $0x1,%edi
  8018aa:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018ad:	fd                   	std    
  8018ae:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b0:	fc                   	cld    
  8018b1:	eb 1d                	jmp    8018d0 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b3:	89 f2                	mov    %esi,%edx
  8018b5:	09 c2                	or     %eax,%edx
  8018b7:	f6 c2 03             	test   $0x3,%dl
  8018ba:	75 0f                	jne    8018cb <memmove+0x5f>
  8018bc:	f6 c1 03             	test   $0x3,%cl
  8018bf:	75 0a                	jne    8018cb <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018c1:	c1 e9 02             	shr    $0x2,%ecx
  8018c4:	89 c7                	mov    %eax,%edi
  8018c6:	fc                   	cld    
  8018c7:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018c9:	eb 05                	jmp    8018d0 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018cb:	89 c7                	mov    %eax,%edi
  8018cd:	fc                   	cld    
  8018ce:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d0:	5e                   	pop    %esi
  8018d1:	5f                   	pop    %edi
  8018d2:	5d                   	pop    %ebp
  8018d3:	c3                   	ret    

008018d4 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d4:	55                   	push   %ebp
  8018d5:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018d7:	ff 75 10             	pushl  0x10(%ebp)
  8018da:	ff 75 0c             	pushl  0xc(%ebp)
  8018dd:	ff 75 08             	pushl  0x8(%ebp)
  8018e0:	e8 87 ff ff ff       	call   80186c <memmove>
}
  8018e5:	c9                   	leave  
  8018e6:	c3                   	ret    

008018e7 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018e7:	55                   	push   %ebp
  8018e8:	89 e5                	mov    %esp,%ebp
  8018ea:	56                   	push   %esi
  8018eb:	53                   	push   %ebx
  8018ec:	8b 45 08             	mov    0x8(%ebp),%eax
  8018ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f2:	89 c6                	mov    %eax,%esi
  8018f4:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018f7:	eb 1a                	jmp    801913 <memcmp+0x2c>
		if (*s1 != *s2)
  8018f9:	0f b6 08             	movzbl (%eax),%ecx
  8018fc:	0f b6 1a             	movzbl (%edx),%ebx
  8018ff:	38 d9                	cmp    %bl,%cl
  801901:	74 0a                	je     80190d <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801903:	0f b6 c1             	movzbl %cl,%eax
  801906:	0f b6 db             	movzbl %bl,%ebx
  801909:	29 d8                	sub    %ebx,%eax
  80190b:	eb 0f                	jmp    80191c <memcmp+0x35>
		s1++, s2++;
  80190d:	83 c0 01             	add    $0x1,%eax
  801910:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801913:	39 f0                	cmp    %esi,%eax
  801915:	75 e2                	jne    8018f9 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801917:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80191c:	5b                   	pop    %ebx
  80191d:	5e                   	pop    %esi
  80191e:	5d                   	pop    %ebp
  80191f:	c3                   	ret    

00801920 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801920:	55                   	push   %ebp
  801921:	89 e5                	mov    %esp,%ebp
  801923:	53                   	push   %ebx
  801924:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801927:	89 c1                	mov    %eax,%ecx
  801929:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  80192c:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801930:	eb 0a                	jmp    80193c <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801932:	0f b6 10             	movzbl (%eax),%edx
  801935:	39 da                	cmp    %ebx,%edx
  801937:	74 07                	je     801940 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801939:	83 c0 01             	add    $0x1,%eax
  80193c:	39 c8                	cmp    %ecx,%eax
  80193e:	72 f2                	jb     801932 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801940:	5b                   	pop    %ebx
  801941:	5d                   	pop    %ebp
  801942:	c3                   	ret    

00801943 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801943:	55                   	push   %ebp
  801944:	89 e5                	mov    %esp,%ebp
  801946:	57                   	push   %edi
  801947:	56                   	push   %esi
  801948:	53                   	push   %ebx
  801949:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80194c:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80194f:	eb 03                	jmp    801954 <strtol+0x11>
		s++;
  801951:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801954:	0f b6 01             	movzbl (%ecx),%eax
  801957:	3c 20                	cmp    $0x20,%al
  801959:	74 f6                	je     801951 <strtol+0xe>
  80195b:	3c 09                	cmp    $0x9,%al
  80195d:	74 f2                	je     801951 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80195f:	3c 2b                	cmp    $0x2b,%al
  801961:	75 0a                	jne    80196d <strtol+0x2a>
		s++;
  801963:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801966:	bf 00 00 00 00       	mov    $0x0,%edi
  80196b:	eb 11                	jmp    80197e <strtol+0x3b>
  80196d:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801972:	3c 2d                	cmp    $0x2d,%al
  801974:	75 08                	jne    80197e <strtol+0x3b>
		s++, neg = 1;
  801976:	83 c1 01             	add    $0x1,%ecx
  801979:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80197e:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801984:	75 15                	jne    80199b <strtol+0x58>
  801986:	80 39 30             	cmpb   $0x30,(%ecx)
  801989:	75 10                	jne    80199b <strtol+0x58>
  80198b:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80198f:	75 7c                	jne    801a0d <strtol+0xca>
		s += 2, base = 16;
  801991:	83 c1 02             	add    $0x2,%ecx
  801994:	bb 10 00 00 00       	mov    $0x10,%ebx
  801999:	eb 16                	jmp    8019b1 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  80199b:	85 db                	test   %ebx,%ebx
  80199d:	75 12                	jne    8019b1 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  80199f:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a4:	80 39 30             	cmpb   $0x30,(%ecx)
  8019a7:	75 08                	jne    8019b1 <strtol+0x6e>
		s++, base = 8;
  8019a9:	83 c1 01             	add    $0x1,%ecx
  8019ac:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8019b6:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019b9:	0f b6 11             	movzbl (%ecx),%edx
  8019bc:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019bf:	89 f3                	mov    %esi,%ebx
  8019c1:	80 fb 09             	cmp    $0x9,%bl
  8019c4:	77 08                	ja     8019ce <strtol+0x8b>
			dig = *s - '0';
  8019c6:	0f be d2             	movsbl %dl,%edx
  8019c9:	83 ea 30             	sub    $0x30,%edx
  8019cc:	eb 22                	jmp    8019f0 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019ce:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d1:	89 f3                	mov    %esi,%ebx
  8019d3:	80 fb 19             	cmp    $0x19,%bl
  8019d6:	77 08                	ja     8019e0 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019d8:	0f be d2             	movsbl %dl,%edx
  8019db:	83 ea 57             	sub    $0x57,%edx
  8019de:	eb 10                	jmp    8019f0 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019e0:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019e3:	89 f3                	mov    %esi,%ebx
  8019e5:	80 fb 19             	cmp    $0x19,%bl
  8019e8:	77 16                	ja     801a00 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019ea:	0f be d2             	movsbl %dl,%edx
  8019ed:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019f0:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f3:	7d 0b                	jge    801a00 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019f5:	83 c1 01             	add    $0x1,%ecx
  8019f8:	0f af 45 10          	imul   0x10(%ebp),%eax
  8019fc:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  8019fe:	eb b9                	jmp    8019b9 <strtol+0x76>

	if (endptr)
  801a00:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a04:	74 0d                	je     801a13 <strtol+0xd0>
		*endptr = (char *) s;
  801a06:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a09:	89 0e                	mov    %ecx,(%esi)
  801a0b:	eb 06                	jmp    801a13 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a0d:	85 db                	test   %ebx,%ebx
  801a0f:	74 98                	je     8019a9 <strtol+0x66>
  801a11:	eb 9e                	jmp    8019b1 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a13:	89 c2                	mov    %eax,%edx
  801a15:	f7 da                	neg    %edx
  801a17:	85 ff                	test   %edi,%edi
  801a19:	0f 45 c2             	cmovne %edx,%eax
}
  801a1c:	5b                   	pop    %ebx
  801a1d:	5e                   	pop    %esi
  801a1e:	5f                   	pop    %edi
  801a1f:	5d                   	pop    %ebp
  801a20:	c3                   	ret    

00801a21 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a21:	55                   	push   %ebp
  801a22:	89 e5                	mov    %esp,%ebp
  801a24:	56                   	push   %esi
  801a25:	53                   	push   %ebx
  801a26:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a29:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801a2c:	83 ec 0c             	sub    $0xc,%esp
  801a2f:	ff 75 0c             	pushl  0xc(%ebp)
  801a32:	e8 d7 e8 ff ff       	call   80030e <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801a37:	83 c4 10             	add    $0x10,%esp
  801a3a:	85 f6                	test   %esi,%esi
  801a3c:	74 1c                	je     801a5a <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801a3e:	a1 04 40 80 00       	mov    0x804004,%eax
  801a43:	8b 40 78             	mov    0x78(%eax),%eax
  801a46:	89 06                	mov    %eax,(%esi)
  801a48:	eb 10                	jmp    801a5a <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801a4a:	83 ec 0c             	sub    $0xc,%esp
  801a4d:	68 20 22 80 00       	push   $0x802220
  801a52:	e8 b4 f6 ff ff       	call   80110b <cprintf>
  801a57:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801a5a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a5f:	8b 50 74             	mov    0x74(%eax),%edx
  801a62:	85 d2                	test   %edx,%edx
  801a64:	74 e4                	je     801a4a <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801a66:	85 db                	test   %ebx,%ebx
  801a68:	74 05                	je     801a6f <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801a6a:	8b 40 74             	mov    0x74(%eax),%eax
  801a6d:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a6f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a74:	8b 40 70             	mov    0x70(%eax),%eax

}
  801a77:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7a:	5b                   	pop    %ebx
  801a7b:	5e                   	pop    %esi
  801a7c:	5d                   	pop    %ebp
  801a7d:	c3                   	ret    

00801a7e <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a7e:	55                   	push   %ebp
  801a7f:	89 e5                	mov    %esp,%ebp
  801a81:	57                   	push   %edi
  801a82:	56                   	push   %esi
  801a83:	53                   	push   %ebx
  801a84:	83 ec 0c             	sub    $0xc,%esp
  801a87:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a8a:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a8d:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801a90:	85 db                	test   %ebx,%ebx
  801a92:	75 13                	jne    801aa7 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801a94:	6a 00                	push   $0x0
  801a96:	68 00 00 c0 ee       	push   $0xeec00000
  801a9b:	56                   	push   %esi
  801a9c:	57                   	push   %edi
  801a9d:	e8 49 e8 ff ff       	call   8002eb <sys_ipc_try_send>
  801aa2:	83 c4 10             	add    $0x10,%esp
  801aa5:	eb 0e                	jmp    801ab5 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801aa7:	ff 75 14             	pushl  0x14(%ebp)
  801aaa:	53                   	push   %ebx
  801aab:	56                   	push   %esi
  801aac:	57                   	push   %edi
  801aad:	e8 39 e8 ff ff       	call   8002eb <sys_ipc_try_send>
  801ab2:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801ab5:	85 c0                	test   %eax,%eax
  801ab7:	75 d7                	jne    801a90 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801ab9:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801abc:	5b                   	pop    %ebx
  801abd:	5e                   	pop    %esi
  801abe:	5f                   	pop    %edi
  801abf:	5d                   	pop    %ebp
  801ac0:	c3                   	ret    

00801ac1 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac1:	55                   	push   %ebp
  801ac2:	89 e5                	mov    %esp,%ebp
  801ac4:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ac7:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801acc:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801acf:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ad5:	8b 52 50             	mov    0x50(%edx),%edx
  801ad8:	39 ca                	cmp    %ecx,%edx
  801ada:	75 0d                	jne    801ae9 <ipc_find_env+0x28>
			return envs[i].env_id;
  801adc:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801adf:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ae4:	8b 40 48             	mov    0x48(%eax),%eax
  801ae7:	eb 0f                	jmp    801af8 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801ae9:	83 c0 01             	add    $0x1,%eax
  801aec:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af1:	75 d9                	jne    801acc <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af3:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801af8:	5d                   	pop    %ebp
  801af9:	c3                   	ret    

00801afa <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801afa:	55                   	push   %ebp
  801afb:	89 e5                	mov    %esp,%ebp
  801afd:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b00:	89 d0                	mov    %edx,%eax
  801b02:	c1 e8 16             	shr    $0x16,%eax
  801b05:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b0c:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b11:	f6 c1 01             	test   $0x1,%cl
  801b14:	74 1d                	je     801b33 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b16:	c1 ea 0c             	shr    $0xc,%edx
  801b19:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b20:	f6 c2 01             	test   $0x1,%dl
  801b23:	74 0e                	je     801b33 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b25:	c1 ea 0c             	shr    $0xc,%edx
  801b28:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b2f:	ef 
  801b30:	0f b7 c0             	movzwl %ax,%eax
}
  801b33:	5d                   	pop    %ebp
  801b34:	c3                   	ret    
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
