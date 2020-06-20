
obj/user/buggyhello2.debug:     file format elf32-i386


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
  80002c:	e8 1d 00 00 00       	call   80004e <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

const char *hello = "hello, world\n";

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs(hello, 1024*1024);
  800039:	68 00 00 10 00       	push   $0x100000
  80003e:	ff 35 00 30 80 00    	pushl  0x803000
  800044:	e8 65 00 00 00       	call   8000ae <sys_cputs>
}
  800049:	83 c4 10             	add    $0x10,%esp
  80004c:	c9                   	leave  
  80004d:	c3                   	ret    

0080004e <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  80004e:	55                   	push   %ebp
  80004f:	89 e5                	mov    %esp,%ebp
  800051:	56                   	push   %esi
  800052:	53                   	push   %ebx
  800053:	8b 5d 08             	mov    0x8(%ebp),%ebx
  800056:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800059:	e8 ce 00 00 00       	call   80012c <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 30 80 00       	mov    %eax,0x803004

	// call user main routine
	umain(argc, argv);
  80007b:	83 ec 08             	sub    $0x8,%esp
  80007e:	56                   	push   %esi
  80007f:	53                   	push   %ebx
  800080:	e8 ae ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  800085:	e8 0a 00 00 00       	call   800094 <exit>
}
  80008a:	83 c4 10             	add    $0x10,%esp
  80008d:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800090:	5b                   	pop    %ebx
  800091:	5e                   	pop    %esi
  800092:	5d                   	pop    %ebp
  800093:	c3                   	ret    

00800094 <exit>:

#include <inc/lib.h>

void
exit(void)
{
  800094:	55                   	push   %ebp
  800095:	89 e5                	mov    %esp,%ebp
  800097:	83 ec 08             	sub    $0x8,%esp
	close_all();
  80009a:	e8 87 04 00 00       	call   800526 <close_all>
	sys_env_destroy(0);
  80009f:	83 ec 0c             	sub    $0xc,%esp
  8000a2:	6a 00                	push   $0x0
  8000a4:	e8 42 00 00 00       	call   8000eb <sys_env_destroy>
}
  8000a9:	83 c4 10             	add    $0x10,%esp
  8000ac:	c9                   	leave  
  8000ad:	c3                   	ret    

008000ae <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000ae:	55                   	push   %ebp
  8000af:	89 e5                	mov    %esp,%ebp
  8000b1:	57                   	push   %edi
  8000b2:	56                   	push   %esi
  8000b3:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000b4:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000bc:	8b 55 08             	mov    0x8(%ebp),%edx
  8000bf:	89 c3                	mov    %eax,%ebx
  8000c1:	89 c7                	mov    %eax,%edi
  8000c3:	89 c6                	mov    %eax,%esi
  8000c5:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c7:	5b                   	pop    %ebx
  8000c8:	5e                   	pop    %esi
  8000c9:	5f                   	pop    %edi
  8000ca:	5d                   	pop    %ebp
  8000cb:	c3                   	ret    

008000cc <sys_cgetc>:

int
sys_cgetc(void)
{
  8000cc:	55                   	push   %ebp
  8000cd:	89 e5                	mov    %esp,%ebp
  8000cf:	57                   	push   %edi
  8000d0:	56                   	push   %esi
  8000d1:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000d2:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d7:	b8 01 00 00 00       	mov    $0x1,%eax
  8000dc:	89 d1                	mov    %edx,%ecx
  8000de:	89 d3                	mov    %edx,%ebx
  8000e0:	89 d7                	mov    %edx,%edi
  8000e2:	89 d6                	mov    %edx,%esi
  8000e4:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000e6:	5b                   	pop    %ebx
  8000e7:	5e                   	pop    %esi
  8000e8:	5f                   	pop    %edi
  8000e9:	5d                   	pop    %ebp
  8000ea:	c3                   	ret    

008000eb <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000eb:	55                   	push   %ebp
  8000ec:	89 e5                	mov    %esp,%ebp
  8000ee:	57                   	push   %edi
  8000ef:	56                   	push   %esi
  8000f0:	53                   	push   %ebx
  8000f1:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000f4:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f9:	b8 03 00 00 00       	mov    $0x3,%eax
  8000fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800101:	89 cb                	mov    %ecx,%ebx
  800103:	89 cf                	mov    %ecx,%edi
  800105:	89 ce                	mov    %ecx,%esi
  800107:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800109:	85 c0                	test   %eax,%eax
  80010b:	7e 17                	jle    800124 <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80010d:	83 ec 0c             	sub    $0xc,%esp
  800110:	50                   	push   %eax
  800111:	6a 03                	push   $0x3
  800113:	68 f8 1d 80 00       	push   $0x801df8
  800118:	6a 23                	push   $0x23
  80011a:	68 15 1e 80 00       	push   $0x801e15
  80011f:	e8 1a 0f 00 00       	call   80103e <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  800124:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800127:	5b                   	pop    %ebx
  800128:	5e                   	pop    %esi
  800129:	5f                   	pop    %edi
  80012a:	5d                   	pop    %ebp
  80012b:	c3                   	ret    

0080012c <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  80012c:	55                   	push   %ebp
  80012d:	89 e5                	mov    %esp,%ebp
  80012f:	57                   	push   %edi
  800130:	56                   	push   %esi
  800131:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800132:	ba 00 00 00 00       	mov    $0x0,%edx
  800137:	b8 02 00 00 00       	mov    $0x2,%eax
  80013c:	89 d1                	mov    %edx,%ecx
  80013e:	89 d3                	mov    %edx,%ebx
  800140:	89 d7                	mov    %edx,%edi
  800142:	89 d6                	mov    %edx,%esi
  800144:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  800146:	5b                   	pop    %ebx
  800147:	5e                   	pop    %esi
  800148:	5f                   	pop    %edi
  800149:	5d                   	pop    %ebp
  80014a:	c3                   	ret    

0080014b <sys_yield>:

void
sys_yield(void)
{
  80014b:	55                   	push   %ebp
  80014c:	89 e5                	mov    %esp,%ebp
  80014e:	57                   	push   %edi
  80014f:	56                   	push   %esi
  800150:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800151:	ba 00 00 00 00       	mov    $0x0,%edx
  800156:	b8 0b 00 00 00       	mov    $0xb,%eax
  80015b:	89 d1                	mov    %edx,%ecx
  80015d:	89 d3                	mov    %edx,%ebx
  80015f:	89 d7                	mov    %edx,%edi
  800161:	89 d6                	mov    %edx,%esi
  800163:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  800165:	5b                   	pop    %ebx
  800166:	5e                   	pop    %esi
  800167:	5f                   	pop    %edi
  800168:	5d                   	pop    %ebp
  800169:	c3                   	ret    

0080016a <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  80016a:	55                   	push   %ebp
  80016b:	89 e5                	mov    %esp,%ebp
  80016d:	57                   	push   %edi
  80016e:	56                   	push   %esi
  80016f:	53                   	push   %ebx
  800170:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800173:	be 00 00 00 00       	mov    $0x0,%esi
  800178:	b8 04 00 00 00       	mov    $0x4,%eax
  80017d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800180:	8b 55 08             	mov    0x8(%ebp),%edx
  800183:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800186:	89 f7                	mov    %esi,%edi
  800188:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80018a:	85 c0                	test   %eax,%eax
  80018c:	7e 17                	jle    8001a5 <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  80018e:	83 ec 0c             	sub    $0xc,%esp
  800191:	50                   	push   %eax
  800192:	6a 04                	push   $0x4
  800194:	68 f8 1d 80 00       	push   $0x801df8
  800199:	6a 23                	push   $0x23
  80019b:	68 15 1e 80 00       	push   $0x801e15
  8001a0:	e8 99 0e 00 00       	call   80103e <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  8001a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a8:	5b                   	pop    %ebx
  8001a9:	5e                   	pop    %esi
  8001aa:	5f                   	pop    %edi
  8001ab:	5d                   	pop    %ebp
  8001ac:	c3                   	ret    

008001ad <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001ad:	55                   	push   %ebp
  8001ae:	89 e5                	mov    %esp,%ebp
  8001b0:	57                   	push   %edi
  8001b1:	56                   	push   %esi
  8001b2:	53                   	push   %ebx
  8001b3:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001b6:	b8 05 00 00 00       	mov    $0x5,%eax
  8001bb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001be:	8b 55 08             	mov    0x8(%ebp),%edx
  8001c1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001c4:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c7:	8b 75 18             	mov    0x18(%ebp),%esi
  8001ca:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8001cc:	85 c0                	test   %eax,%eax
  8001ce:	7e 17                	jle    8001e7 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001d0:	83 ec 0c             	sub    $0xc,%esp
  8001d3:	50                   	push   %eax
  8001d4:	6a 05                	push   $0x5
  8001d6:	68 f8 1d 80 00       	push   $0x801df8
  8001db:	6a 23                	push   $0x23
  8001dd:	68 15 1e 80 00       	push   $0x801e15
  8001e2:	e8 57 0e 00 00       	call   80103e <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001ea:	5b                   	pop    %ebx
  8001eb:	5e                   	pop    %esi
  8001ec:	5f                   	pop    %edi
  8001ed:	5d                   	pop    %ebp
  8001ee:	c3                   	ret    

008001ef <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001ef:	55                   	push   %ebp
  8001f0:	89 e5                	mov    %esp,%ebp
  8001f2:	57                   	push   %edi
  8001f3:	56                   	push   %esi
  8001f4:	53                   	push   %ebx
  8001f5:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001f8:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001fd:	b8 06 00 00 00       	mov    $0x6,%eax
  800202:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800205:	8b 55 08             	mov    0x8(%ebp),%edx
  800208:	89 df                	mov    %ebx,%edi
  80020a:	89 de                	mov    %ebx,%esi
  80020c:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80020e:	85 c0                	test   %eax,%eax
  800210:	7e 17                	jle    800229 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800212:	83 ec 0c             	sub    $0xc,%esp
  800215:	50                   	push   %eax
  800216:	6a 06                	push   $0x6
  800218:	68 f8 1d 80 00       	push   $0x801df8
  80021d:	6a 23                	push   $0x23
  80021f:	68 15 1e 80 00       	push   $0x801e15
  800224:	e8 15 0e 00 00       	call   80103e <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800229:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80022c:	5b                   	pop    %ebx
  80022d:	5e                   	pop    %esi
  80022e:	5f                   	pop    %edi
  80022f:	5d                   	pop    %ebp
  800230:	c3                   	ret    

00800231 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800231:	55                   	push   %ebp
  800232:	89 e5                	mov    %esp,%ebp
  800234:	57                   	push   %edi
  800235:	56                   	push   %esi
  800236:	53                   	push   %ebx
  800237:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80023a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80023f:	b8 08 00 00 00       	mov    $0x8,%eax
  800244:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800247:	8b 55 08             	mov    0x8(%ebp),%edx
  80024a:	89 df                	mov    %ebx,%edi
  80024c:	89 de                	mov    %ebx,%esi
  80024e:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800250:	85 c0                	test   %eax,%eax
  800252:	7e 17                	jle    80026b <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800254:	83 ec 0c             	sub    $0xc,%esp
  800257:	50                   	push   %eax
  800258:	6a 08                	push   $0x8
  80025a:	68 f8 1d 80 00       	push   $0x801df8
  80025f:	6a 23                	push   $0x23
  800261:	68 15 1e 80 00       	push   $0x801e15
  800266:	e8 d3 0d 00 00       	call   80103e <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  80026b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80026e:	5b                   	pop    %ebx
  80026f:	5e                   	pop    %esi
  800270:	5f                   	pop    %edi
  800271:	5d                   	pop    %ebp
  800272:	c3                   	ret    

00800273 <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  800273:	55                   	push   %ebp
  800274:	89 e5                	mov    %esp,%ebp
  800276:	57                   	push   %edi
  800277:	56                   	push   %esi
  800278:	53                   	push   %ebx
  800279:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80027c:	bb 00 00 00 00       	mov    $0x0,%ebx
  800281:	b8 09 00 00 00       	mov    $0x9,%eax
  800286:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800289:	8b 55 08             	mov    0x8(%ebp),%edx
  80028c:	89 df                	mov    %ebx,%edi
  80028e:	89 de                	mov    %ebx,%esi
  800290:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800292:	85 c0                	test   %eax,%eax
  800294:	7e 17                	jle    8002ad <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  800296:	83 ec 0c             	sub    $0xc,%esp
  800299:	50                   	push   %eax
  80029a:	6a 09                	push   $0x9
  80029c:	68 f8 1d 80 00       	push   $0x801df8
  8002a1:	6a 23                	push   $0x23
  8002a3:	68 15 1e 80 00       	push   $0x801e15
  8002a8:	e8 91 0d 00 00       	call   80103e <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002ad:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002b0:	5b                   	pop    %ebx
  8002b1:	5e                   	pop    %esi
  8002b2:	5f                   	pop    %edi
  8002b3:	5d                   	pop    %ebp
  8002b4:	c3                   	ret    

008002b5 <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002b5:	55                   	push   %ebp
  8002b6:	89 e5                	mov    %esp,%ebp
  8002b8:	57                   	push   %edi
  8002b9:	56                   	push   %esi
  8002ba:	53                   	push   %ebx
  8002bb:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002be:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002c3:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c8:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002cb:	8b 55 08             	mov    0x8(%ebp),%edx
  8002ce:	89 df                	mov    %ebx,%edi
  8002d0:	89 de                	mov    %ebx,%esi
  8002d2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8002d4:	85 c0                	test   %eax,%eax
  8002d6:	7e 17                	jle    8002ef <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d8:	83 ec 0c             	sub    $0xc,%esp
  8002db:	50                   	push   %eax
  8002dc:	6a 0a                	push   $0xa
  8002de:	68 f8 1d 80 00       	push   $0x801df8
  8002e3:	6a 23                	push   $0x23
  8002e5:	68 15 1e 80 00       	push   $0x801e15
  8002ea:	e8 4f 0d 00 00       	call   80103e <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002f2:	5b                   	pop    %ebx
  8002f3:	5e                   	pop    %esi
  8002f4:	5f                   	pop    %edi
  8002f5:	5d                   	pop    %ebp
  8002f6:	c3                   	ret    

008002f7 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f7:	55                   	push   %ebp
  8002f8:	89 e5                	mov    %esp,%ebp
  8002fa:	57                   	push   %edi
  8002fb:	56                   	push   %esi
  8002fc:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002fd:	be 00 00 00 00       	mov    $0x0,%esi
  800302:	b8 0c 00 00 00       	mov    $0xc,%eax
  800307:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80030a:	8b 55 08             	mov    0x8(%ebp),%edx
  80030d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800310:	8b 7d 14             	mov    0x14(%ebp),%edi
  800313:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  800315:	5b                   	pop    %ebx
  800316:	5e                   	pop    %esi
  800317:	5f                   	pop    %edi
  800318:	5d                   	pop    %ebp
  800319:	c3                   	ret    

0080031a <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  80031a:	55                   	push   %ebp
  80031b:	89 e5                	mov    %esp,%ebp
  80031d:	57                   	push   %edi
  80031e:	56                   	push   %esi
  80031f:	53                   	push   %ebx
  800320:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800323:	b9 00 00 00 00       	mov    $0x0,%ecx
  800328:	b8 0d 00 00 00       	mov    $0xd,%eax
  80032d:	8b 55 08             	mov    0x8(%ebp),%edx
  800330:	89 cb                	mov    %ecx,%ebx
  800332:	89 cf                	mov    %ecx,%edi
  800334:	89 ce                	mov    %ecx,%esi
  800336:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800338:	85 c0                	test   %eax,%eax
  80033a:	7e 17                	jle    800353 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  80033c:	83 ec 0c             	sub    $0xc,%esp
  80033f:	50                   	push   %eax
  800340:	6a 0d                	push   $0xd
  800342:	68 f8 1d 80 00       	push   $0x801df8
  800347:	6a 23                	push   $0x23
  800349:	68 15 1e 80 00       	push   $0x801e15
  80034e:	e8 eb 0c 00 00       	call   80103e <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800353:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800356:	5b                   	pop    %ebx
  800357:	5e                   	pop    %esi
  800358:	5f                   	pop    %edi
  800359:	5d                   	pop    %ebp
  80035a:	c3                   	ret    

0080035b <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  80035b:	55                   	push   %ebp
  80035c:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  80035e:	8b 45 08             	mov    0x8(%ebp),%eax
  800361:	05 00 00 00 30       	add    $0x30000000,%eax
  800366:	c1 e8 0c             	shr    $0xc,%eax
}
  800369:	5d                   	pop    %ebp
  80036a:	c3                   	ret    

0080036b <fd2data>:

char*
fd2data(struct Fd *fd)
{
  80036b:	55                   	push   %ebp
  80036c:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  80036e:	8b 45 08             	mov    0x8(%ebp),%eax
  800371:	05 00 00 00 30       	add    $0x30000000,%eax
  800376:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  80037b:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800380:	5d                   	pop    %ebp
  800381:	c3                   	ret    

00800382 <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  800382:	55                   	push   %ebp
  800383:	89 e5                	mov    %esp,%ebp
  800385:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800388:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  80038d:	89 c2                	mov    %eax,%edx
  80038f:	c1 ea 16             	shr    $0x16,%edx
  800392:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800399:	f6 c2 01             	test   $0x1,%dl
  80039c:	74 11                	je     8003af <fd_alloc+0x2d>
  80039e:	89 c2                	mov    %eax,%edx
  8003a0:	c1 ea 0c             	shr    $0xc,%edx
  8003a3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003aa:	f6 c2 01             	test   $0x1,%dl
  8003ad:	75 09                	jne    8003b8 <fd_alloc+0x36>
			*fd_store = fd;
  8003af:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003b1:	b8 00 00 00 00       	mov    $0x0,%eax
  8003b6:	eb 17                	jmp    8003cf <fd_alloc+0x4d>
  8003b8:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003bd:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003c2:	75 c9                	jne    80038d <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003c4:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003ca:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003cf:	5d                   	pop    %ebp
  8003d0:	c3                   	ret    

008003d1 <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003d1:	55                   	push   %ebp
  8003d2:	89 e5                	mov    %esp,%ebp
  8003d4:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d7:	83 f8 1f             	cmp    $0x1f,%eax
  8003da:	77 36                	ja     800412 <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003dc:	c1 e0 0c             	shl    $0xc,%eax
  8003df:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003e4:	89 c2                	mov    %eax,%edx
  8003e6:	c1 ea 16             	shr    $0x16,%edx
  8003e9:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003f0:	f6 c2 01             	test   $0x1,%dl
  8003f3:	74 24                	je     800419 <fd_lookup+0x48>
  8003f5:	89 c2                	mov    %eax,%edx
  8003f7:	c1 ea 0c             	shr    $0xc,%edx
  8003fa:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  800401:	f6 c2 01             	test   $0x1,%dl
  800404:	74 1a                	je     800420 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  800406:	8b 55 0c             	mov    0xc(%ebp),%edx
  800409:	89 02                	mov    %eax,(%edx)
	return 0;
  80040b:	b8 00 00 00 00       	mov    $0x0,%eax
  800410:	eb 13                	jmp    800425 <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 0c                	jmp    800425 <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  80041e:	eb 05                	jmp    800425 <fd_lookup+0x54>
  800420:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  800425:	5d                   	pop    %ebp
  800426:	c3                   	ret    

00800427 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800427:	55                   	push   %ebp
  800428:	89 e5                	mov    %esp,%ebp
  80042a:	83 ec 08             	sub    $0x8,%esp
  80042d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800430:	ba a0 1e 80 00       	mov    $0x801ea0,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  800435:	eb 13                	jmp    80044a <dev_lookup+0x23>
  800437:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  80043a:	39 08                	cmp    %ecx,(%eax)
  80043c:	75 0c                	jne    80044a <dev_lookup+0x23>
			*dev = devtab[i];
  80043e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800441:	89 01                	mov    %eax,(%ecx)
			return 0;
  800443:	b8 00 00 00 00       	mov    $0x0,%eax
  800448:	eb 2e                	jmp    800478 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  80044a:	8b 02                	mov    (%edx),%eax
  80044c:	85 c0                	test   %eax,%eax
  80044e:	75 e7                	jne    800437 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800450:	a1 04 40 80 00       	mov    0x804004,%eax
  800455:	8b 40 48             	mov    0x48(%eax),%eax
  800458:	83 ec 04             	sub    $0x4,%esp
  80045b:	51                   	push   %ecx
  80045c:	50                   	push   %eax
  80045d:	68 24 1e 80 00       	push   $0x801e24
  800462:	e8 b0 0c 00 00       	call   801117 <cprintf>
	*dev = 0;
  800467:	8b 45 0c             	mov    0xc(%ebp),%eax
  80046a:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800470:	83 c4 10             	add    $0x10,%esp
  800473:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800478:	c9                   	leave  
  800479:	c3                   	ret    

0080047a <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  80047a:	55                   	push   %ebp
  80047b:	89 e5                	mov    %esp,%ebp
  80047d:	56                   	push   %esi
  80047e:	53                   	push   %ebx
  80047f:	83 ec 10             	sub    $0x10,%esp
  800482:	8b 75 08             	mov    0x8(%ebp),%esi
  800485:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800488:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80048b:	50                   	push   %eax
  80048c:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  800492:	c1 e8 0c             	shr    $0xc,%eax
  800495:	50                   	push   %eax
  800496:	e8 36 ff ff ff       	call   8003d1 <fd_lookup>
  80049b:	83 c4 08             	add    $0x8,%esp
  80049e:	85 c0                	test   %eax,%eax
  8004a0:	78 05                	js     8004a7 <fd_close+0x2d>
	    || fd != fd2)
  8004a2:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  8004a5:	74 0c                	je     8004b3 <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a7:	84 db                	test   %bl,%bl
  8004a9:	ba 00 00 00 00       	mov    $0x0,%edx
  8004ae:	0f 44 c2             	cmove  %edx,%eax
  8004b1:	eb 41                	jmp    8004f4 <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004b3:	83 ec 08             	sub    $0x8,%esp
  8004b6:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b9:	50                   	push   %eax
  8004ba:	ff 36                	pushl  (%esi)
  8004bc:	e8 66 ff ff ff       	call   800427 <dev_lookup>
  8004c1:	89 c3                	mov    %eax,%ebx
  8004c3:	83 c4 10             	add    $0x10,%esp
  8004c6:	85 c0                	test   %eax,%eax
  8004c8:	78 1a                	js     8004e4 <fd_close+0x6a>
		if (dev->dev_close)
  8004ca:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004cd:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004d0:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004d5:	85 c0                	test   %eax,%eax
  8004d7:	74 0b                	je     8004e4 <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d9:	83 ec 0c             	sub    $0xc,%esp
  8004dc:	56                   	push   %esi
  8004dd:	ff d0                	call   *%eax
  8004df:	89 c3                	mov    %eax,%ebx
  8004e1:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004e4:	83 ec 08             	sub    $0x8,%esp
  8004e7:	56                   	push   %esi
  8004e8:	6a 00                	push   $0x0
  8004ea:	e8 00 fd ff ff       	call   8001ef <sys_page_unmap>
	return r;
  8004ef:	83 c4 10             	add    $0x10,%esp
  8004f2:	89 d8                	mov    %ebx,%eax
}
  8004f4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f7:	5b                   	pop    %ebx
  8004f8:	5e                   	pop    %esi
  8004f9:	5d                   	pop    %ebp
  8004fa:	c3                   	ret    

008004fb <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004fb:	55                   	push   %ebp
  8004fc:	89 e5                	mov    %esp,%ebp
  8004fe:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800501:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800504:	50                   	push   %eax
  800505:	ff 75 08             	pushl  0x8(%ebp)
  800508:	e8 c4 fe ff ff       	call   8003d1 <fd_lookup>
  80050d:	83 c4 08             	add    $0x8,%esp
  800510:	85 c0                	test   %eax,%eax
  800512:	78 10                	js     800524 <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  800514:	83 ec 08             	sub    $0x8,%esp
  800517:	6a 01                	push   $0x1
  800519:	ff 75 f4             	pushl  -0xc(%ebp)
  80051c:	e8 59 ff ff ff       	call   80047a <fd_close>
  800521:	83 c4 10             	add    $0x10,%esp
}
  800524:	c9                   	leave  
  800525:	c3                   	ret    

00800526 <close_all>:

void
close_all(void)
{
  800526:	55                   	push   %ebp
  800527:	89 e5                	mov    %esp,%ebp
  800529:	53                   	push   %ebx
  80052a:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  80052d:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  800532:	83 ec 0c             	sub    $0xc,%esp
  800535:	53                   	push   %ebx
  800536:	e8 c0 ff ff ff       	call   8004fb <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  80053b:	83 c3 01             	add    $0x1,%ebx
  80053e:	83 c4 10             	add    $0x10,%esp
  800541:	83 fb 20             	cmp    $0x20,%ebx
  800544:	75 ec                	jne    800532 <close_all+0xc>
		close(i);
}
  800546:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800549:	c9                   	leave  
  80054a:	c3                   	ret    

0080054b <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  80054b:	55                   	push   %ebp
  80054c:	89 e5                	mov    %esp,%ebp
  80054e:	57                   	push   %edi
  80054f:	56                   	push   %esi
  800550:	53                   	push   %ebx
  800551:	83 ec 2c             	sub    $0x2c,%esp
  800554:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800557:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  80055a:	50                   	push   %eax
  80055b:	ff 75 08             	pushl  0x8(%ebp)
  80055e:	e8 6e fe ff ff       	call   8003d1 <fd_lookup>
  800563:	83 c4 08             	add    $0x8,%esp
  800566:	85 c0                	test   %eax,%eax
  800568:	0f 88 c1 00 00 00    	js     80062f <dup+0xe4>
		return r;
	close(newfdnum);
  80056e:	83 ec 0c             	sub    $0xc,%esp
  800571:	56                   	push   %esi
  800572:	e8 84 ff ff ff       	call   8004fb <close>

	newfd = INDEX2FD(newfdnum);
  800577:	89 f3                	mov    %esi,%ebx
  800579:	c1 e3 0c             	shl    $0xc,%ebx
  80057c:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  800582:	83 c4 04             	add    $0x4,%esp
  800585:	ff 75 e4             	pushl  -0x1c(%ebp)
  800588:	e8 de fd ff ff       	call   80036b <fd2data>
  80058d:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  80058f:	89 1c 24             	mov    %ebx,(%esp)
  800592:	e8 d4 fd ff ff       	call   80036b <fd2data>
  800597:	83 c4 10             	add    $0x10,%esp
  80059a:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  80059d:	89 f8                	mov    %edi,%eax
  80059f:	c1 e8 16             	shr    $0x16,%eax
  8005a2:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a9:	a8 01                	test   $0x1,%al
  8005ab:	74 37                	je     8005e4 <dup+0x99>
  8005ad:	89 f8                	mov    %edi,%eax
  8005af:	c1 e8 0c             	shr    $0xc,%eax
  8005b2:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b9:	f6 c2 01             	test   $0x1,%dl
  8005bc:	74 26                	je     8005e4 <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005be:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005c5:	83 ec 0c             	sub    $0xc,%esp
  8005c8:	25 07 0e 00 00       	and    $0xe07,%eax
  8005cd:	50                   	push   %eax
  8005ce:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005d1:	6a 00                	push   $0x0
  8005d3:	57                   	push   %edi
  8005d4:	6a 00                	push   $0x0
  8005d6:	e8 d2 fb ff ff       	call   8001ad <sys_page_map>
  8005db:	89 c7                	mov    %eax,%edi
  8005dd:	83 c4 20             	add    $0x20,%esp
  8005e0:	85 c0                	test   %eax,%eax
  8005e2:	78 2e                	js     800612 <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005e4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e7:	89 d0                	mov    %edx,%eax
  8005e9:	c1 e8 0c             	shr    $0xc,%eax
  8005ec:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005f3:	83 ec 0c             	sub    $0xc,%esp
  8005f6:	25 07 0e 00 00       	and    $0xe07,%eax
  8005fb:	50                   	push   %eax
  8005fc:	53                   	push   %ebx
  8005fd:	6a 00                	push   $0x0
  8005ff:	52                   	push   %edx
  800600:	6a 00                	push   $0x0
  800602:	e8 a6 fb ff ff       	call   8001ad <sys_page_map>
  800607:	89 c7                	mov    %eax,%edi
  800609:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  80060c:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  80060e:	85 ff                	test   %edi,%edi
  800610:	79 1d                	jns    80062f <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  800612:	83 ec 08             	sub    $0x8,%esp
  800615:	53                   	push   %ebx
  800616:	6a 00                	push   $0x0
  800618:	e8 d2 fb ff ff       	call   8001ef <sys_page_unmap>
	sys_page_unmap(0, nva);
  80061d:	83 c4 08             	add    $0x8,%esp
  800620:	ff 75 d4             	pushl  -0x2c(%ebp)
  800623:	6a 00                	push   $0x0
  800625:	e8 c5 fb ff ff       	call   8001ef <sys_page_unmap>
	return r;
  80062a:	83 c4 10             	add    $0x10,%esp
  80062d:	89 f8                	mov    %edi,%eax
}
  80062f:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800632:	5b                   	pop    %ebx
  800633:	5e                   	pop    %esi
  800634:	5f                   	pop    %edi
  800635:	5d                   	pop    %ebp
  800636:	c3                   	ret    

00800637 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800637:	55                   	push   %ebp
  800638:	89 e5                	mov    %esp,%ebp
  80063a:	53                   	push   %ebx
  80063b:	83 ec 14             	sub    $0x14,%esp
  80063e:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800641:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800644:	50                   	push   %eax
  800645:	53                   	push   %ebx
  800646:	e8 86 fd ff ff       	call   8003d1 <fd_lookup>
  80064b:	83 c4 08             	add    $0x8,%esp
  80064e:	89 c2                	mov    %eax,%edx
  800650:	85 c0                	test   %eax,%eax
  800652:	78 6d                	js     8006c1 <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800654:	83 ec 08             	sub    $0x8,%esp
  800657:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80065a:	50                   	push   %eax
  80065b:	8b 45 f0             	mov    -0x10(%ebp),%eax
  80065e:	ff 30                	pushl  (%eax)
  800660:	e8 c2 fd ff ff       	call   800427 <dev_lookup>
  800665:	83 c4 10             	add    $0x10,%esp
  800668:	85 c0                	test   %eax,%eax
  80066a:	78 4c                	js     8006b8 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  80066c:	8b 55 f0             	mov    -0x10(%ebp),%edx
  80066f:	8b 42 08             	mov    0x8(%edx),%eax
  800672:	83 e0 03             	and    $0x3,%eax
  800675:	83 f8 01             	cmp    $0x1,%eax
  800678:	75 21                	jne    80069b <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  80067a:	a1 04 40 80 00       	mov    0x804004,%eax
  80067f:	8b 40 48             	mov    0x48(%eax),%eax
  800682:	83 ec 04             	sub    $0x4,%esp
  800685:	53                   	push   %ebx
  800686:	50                   	push   %eax
  800687:	68 65 1e 80 00       	push   $0x801e65
  80068c:	e8 86 0a 00 00       	call   801117 <cprintf>
		return -E_INVAL;
  800691:	83 c4 10             	add    $0x10,%esp
  800694:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800699:	eb 26                	jmp    8006c1 <read+0x8a>
	}
	if (!dev->dev_read)
  80069b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80069e:	8b 40 08             	mov    0x8(%eax),%eax
  8006a1:	85 c0                	test   %eax,%eax
  8006a3:	74 17                	je     8006bc <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  8006a5:	83 ec 04             	sub    $0x4,%esp
  8006a8:	ff 75 10             	pushl  0x10(%ebp)
  8006ab:	ff 75 0c             	pushl  0xc(%ebp)
  8006ae:	52                   	push   %edx
  8006af:	ff d0                	call   *%eax
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	83 c4 10             	add    $0x10,%esp
  8006b6:	eb 09                	jmp    8006c1 <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b8:	89 c2                	mov    %eax,%edx
  8006ba:	eb 05                	jmp    8006c1 <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006bc:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006c1:	89 d0                	mov    %edx,%eax
  8006c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006c6:	c9                   	leave  
  8006c7:	c3                   	ret    

008006c8 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c8:	55                   	push   %ebp
  8006c9:	89 e5                	mov    %esp,%ebp
  8006cb:	57                   	push   %edi
  8006cc:	56                   	push   %esi
  8006cd:	53                   	push   %ebx
  8006ce:	83 ec 0c             	sub    $0xc,%esp
  8006d1:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006d4:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006dc:	eb 21                	jmp    8006ff <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006de:	83 ec 04             	sub    $0x4,%esp
  8006e1:	89 f0                	mov    %esi,%eax
  8006e3:	29 d8                	sub    %ebx,%eax
  8006e5:	50                   	push   %eax
  8006e6:	89 d8                	mov    %ebx,%eax
  8006e8:	03 45 0c             	add    0xc(%ebp),%eax
  8006eb:	50                   	push   %eax
  8006ec:	57                   	push   %edi
  8006ed:	e8 45 ff ff ff       	call   800637 <read>
		if (m < 0)
  8006f2:	83 c4 10             	add    $0x10,%esp
  8006f5:	85 c0                	test   %eax,%eax
  8006f7:	78 10                	js     800709 <readn+0x41>
			return m;
		if (m == 0)
  8006f9:	85 c0                	test   %eax,%eax
  8006fb:	74 0a                	je     800707 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006fd:	01 c3                	add    %eax,%ebx
  8006ff:	39 f3                	cmp    %esi,%ebx
  800701:	72 db                	jb     8006de <readn+0x16>
  800703:	89 d8                	mov    %ebx,%eax
  800705:	eb 02                	jmp    800709 <readn+0x41>
  800707:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800709:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80070c:	5b                   	pop    %ebx
  80070d:	5e                   	pop    %esi
  80070e:	5f                   	pop    %edi
  80070f:	5d                   	pop    %ebp
  800710:	c3                   	ret    

00800711 <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  800711:	55                   	push   %ebp
  800712:	89 e5                	mov    %esp,%ebp
  800714:	53                   	push   %ebx
  800715:	83 ec 14             	sub    $0x14,%esp
  800718:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80071b:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80071e:	50                   	push   %eax
  80071f:	53                   	push   %ebx
  800720:	e8 ac fc ff ff       	call   8003d1 <fd_lookup>
  800725:	83 c4 08             	add    $0x8,%esp
  800728:	89 c2                	mov    %eax,%edx
  80072a:	85 c0                	test   %eax,%eax
  80072c:	78 68                	js     800796 <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80072e:	83 ec 08             	sub    $0x8,%esp
  800731:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800734:	50                   	push   %eax
  800735:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800738:	ff 30                	pushl  (%eax)
  80073a:	e8 e8 fc ff ff       	call   800427 <dev_lookup>
  80073f:	83 c4 10             	add    $0x10,%esp
  800742:	85 c0                	test   %eax,%eax
  800744:	78 47                	js     80078d <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  800746:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800749:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  80074d:	75 21                	jne    800770 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  80074f:	a1 04 40 80 00       	mov    0x804004,%eax
  800754:	8b 40 48             	mov    0x48(%eax),%eax
  800757:	83 ec 04             	sub    $0x4,%esp
  80075a:	53                   	push   %ebx
  80075b:	50                   	push   %eax
  80075c:	68 81 1e 80 00       	push   $0x801e81
  800761:	e8 b1 09 00 00       	call   801117 <cprintf>
		return -E_INVAL;
  800766:	83 c4 10             	add    $0x10,%esp
  800769:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80076e:	eb 26                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800770:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800773:	8b 52 0c             	mov    0xc(%edx),%edx
  800776:	85 d2                	test   %edx,%edx
  800778:	74 17                	je     800791 <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  80077a:	83 ec 04             	sub    $0x4,%esp
  80077d:	ff 75 10             	pushl  0x10(%ebp)
  800780:	ff 75 0c             	pushl  0xc(%ebp)
  800783:	50                   	push   %eax
  800784:	ff d2                	call   *%edx
  800786:	89 c2                	mov    %eax,%edx
  800788:	83 c4 10             	add    $0x10,%esp
  80078b:	eb 09                	jmp    800796 <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80078d:	89 c2                	mov    %eax,%edx
  80078f:	eb 05                	jmp    800796 <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  800791:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  800796:	89 d0                	mov    %edx,%eax
  800798:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80079b:	c9                   	leave  
  80079c:	c3                   	ret    

0080079d <seek>:

int
seek(int fdnum, off_t offset)
{
  80079d:	55                   	push   %ebp
  80079e:	89 e5                	mov    %esp,%ebp
  8007a0:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8007a3:	8d 45 fc             	lea    -0x4(%ebp),%eax
  8007a6:	50                   	push   %eax
  8007a7:	ff 75 08             	pushl  0x8(%ebp)
  8007aa:	e8 22 fc ff ff       	call   8003d1 <fd_lookup>
  8007af:	83 c4 08             	add    $0x8,%esp
  8007b2:	85 c0                	test   %eax,%eax
  8007b4:	78 0e                	js     8007c4 <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007b6:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b9:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007bc:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007bf:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007c4:	c9                   	leave  
  8007c5:	c3                   	ret    

008007c6 <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007c6:	55                   	push   %ebp
  8007c7:	89 e5                	mov    %esp,%ebp
  8007c9:	53                   	push   %ebx
  8007ca:	83 ec 14             	sub    $0x14,%esp
  8007cd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007d0:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007d3:	50                   	push   %eax
  8007d4:	53                   	push   %ebx
  8007d5:	e8 f7 fb ff ff       	call   8003d1 <fd_lookup>
  8007da:	83 c4 08             	add    $0x8,%esp
  8007dd:	89 c2                	mov    %eax,%edx
  8007df:	85 c0                	test   %eax,%eax
  8007e1:	78 65                	js     800848 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007e3:	83 ec 08             	sub    $0x8,%esp
  8007e6:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e9:	50                   	push   %eax
  8007ea:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007ed:	ff 30                	pushl  (%eax)
  8007ef:	e8 33 fc ff ff       	call   800427 <dev_lookup>
  8007f4:	83 c4 10             	add    $0x10,%esp
  8007f7:	85 c0                	test   %eax,%eax
  8007f9:	78 44                	js     80083f <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007fb:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007fe:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800802:	75 21                	jne    800825 <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  800804:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800809:	8b 40 48             	mov    0x48(%eax),%eax
  80080c:	83 ec 04             	sub    $0x4,%esp
  80080f:	53                   	push   %ebx
  800810:	50                   	push   %eax
  800811:	68 44 1e 80 00       	push   $0x801e44
  800816:	e8 fc 08 00 00       	call   801117 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  80081b:	83 c4 10             	add    $0x10,%esp
  80081e:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800823:	eb 23                	jmp    800848 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  800825:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800828:	8b 52 18             	mov    0x18(%edx),%edx
  80082b:	85 d2                	test   %edx,%edx
  80082d:	74 14                	je     800843 <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  80082f:	83 ec 08             	sub    $0x8,%esp
  800832:	ff 75 0c             	pushl  0xc(%ebp)
  800835:	50                   	push   %eax
  800836:	ff d2                	call   *%edx
  800838:	89 c2                	mov    %eax,%edx
  80083a:	83 c4 10             	add    $0x10,%esp
  80083d:	eb 09                	jmp    800848 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80083f:	89 c2                	mov    %eax,%edx
  800841:	eb 05                	jmp    800848 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  800843:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800848:	89 d0                	mov    %edx,%eax
  80084a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80084d:	c9                   	leave  
  80084e:	c3                   	ret    

0080084f <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  80084f:	55                   	push   %ebp
  800850:	89 e5                	mov    %esp,%ebp
  800852:	53                   	push   %ebx
  800853:	83 ec 14             	sub    $0x14,%esp
  800856:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800859:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80085c:	50                   	push   %eax
  80085d:	ff 75 08             	pushl  0x8(%ebp)
  800860:	e8 6c fb ff ff       	call   8003d1 <fd_lookup>
  800865:	83 c4 08             	add    $0x8,%esp
  800868:	89 c2                	mov    %eax,%edx
  80086a:	85 c0                	test   %eax,%eax
  80086c:	78 58                	js     8008c6 <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80086e:	83 ec 08             	sub    $0x8,%esp
  800871:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800874:	50                   	push   %eax
  800875:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800878:	ff 30                	pushl  (%eax)
  80087a:	e8 a8 fb ff ff       	call   800427 <dev_lookup>
  80087f:	83 c4 10             	add    $0x10,%esp
  800882:	85 c0                	test   %eax,%eax
  800884:	78 37                	js     8008bd <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  800886:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800889:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  80088d:	74 32                	je     8008c1 <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  80088f:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  800892:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800899:	00 00 00 
	stat->st_isdir = 0;
  80089c:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  8008a3:	00 00 00 
	stat->st_dev = dev;
  8008a6:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008ac:	83 ec 08             	sub    $0x8,%esp
  8008af:	53                   	push   %ebx
  8008b0:	ff 75 f0             	pushl  -0x10(%ebp)
  8008b3:	ff 50 14             	call   *0x14(%eax)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	83 c4 10             	add    $0x10,%esp
  8008bb:	eb 09                	jmp    8008c6 <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008bd:	89 c2                	mov    %eax,%edx
  8008bf:	eb 05                	jmp    8008c6 <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008c1:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008c6:	89 d0                	mov    %edx,%eax
  8008c8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008cb:	c9                   	leave  
  8008cc:	c3                   	ret    

008008cd <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008cd:	55                   	push   %ebp
  8008ce:	89 e5                	mov    %esp,%ebp
  8008d0:	56                   	push   %esi
  8008d1:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008d2:	83 ec 08             	sub    $0x8,%esp
  8008d5:	6a 00                	push   $0x0
  8008d7:	ff 75 08             	pushl  0x8(%ebp)
  8008da:	e8 dc 01 00 00       	call   800abb <open>
  8008df:	89 c3                	mov    %eax,%ebx
  8008e1:	83 c4 10             	add    $0x10,%esp
  8008e4:	85 c0                	test   %eax,%eax
  8008e6:	78 1b                	js     800903 <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e8:	83 ec 08             	sub    $0x8,%esp
  8008eb:	ff 75 0c             	pushl  0xc(%ebp)
  8008ee:	50                   	push   %eax
  8008ef:	e8 5b ff ff ff       	call   80084f <fstat>
  8008f4:	89 c6                	mov    %eax,%esi
	close(fd);
  8008f6:	89 1c 24             	mov    %ebx,(%esp)
  8008f9:	e8 fd fb ff ff       	call   8004fb <close>
	return r;
  8008fe:	83 c4 10             	add    $0x10,%esp
  800901:	89 f0                	mov    %esi,%eax
}
  800903:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800906:	5b                   	pop    %ebx
  800907:	5e                   	pop    %esi
  800908:	5d                   	pop    %ebp
  800909:	c3                   	ret    

0080090a <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  80090a:	55                   	push   %ebp
  80090b:	89 e5                	mov    %esp,%ebp
  80090d:	56                   	push   %esi
  80090e:	53                   	push   %ebx
  80090f:	89 c6                	mov    %eax,%esi
  800911:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  800913:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  80091a:	75 12                	jne    80092e <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  80091c:	83 ec 0c             	sub    $0xc,%esp
  80091f:	6a 01                	push   $0x1
  800921:	e8 a7 11 00 00       	call   801acd <ipc_find_env>
  800926:	a3 00 40 80 00       	mov    %eax,0x804000
  80092b:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  80092e:	6a 07                	push   $0x7
  800930:	68 00 50 80 00       	push   $0x805000
  800935:	56                   	push   %esi
  800936:	ff 35 00 40 80 00    	pushl  0x804000
  80093c:	e8 49 11 00 00       	call   801a8a <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  800941:	83 c4 0c             	add    $0xc,%esp
  800944:	6a 00                	push   $0x0
  800946:	53                   	push   %ebx
  800947:	6a 00                	push   $0x0
  800949:	e8 df 10 00 00       	call   801a2d <ipc_recv>
}
  80094e:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800951:	5b                   	pop    %ebx
  800952:	5e                   	pop    %esi
  800953:	5d                   	pop    %ebp
  800954:	c3                   	ret    

00800955 <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  800955:	55                   	push   %ebp
  800956:	89 e5                	mov    %esp,%ebp
  800958:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  80095b:	8b 45 08             	mov    0x8(%ebp),%eax
  80095e:	8b 40 0c             	mov    0xc(%eax),%eax
  800961:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  800966:	8b 45 0c             	mov    0xc(%ebp),%eax
  800969:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  80096e:	ba 00 00 00 00       	mov    $0x0,%edx
  800973:	b8 02 00 00 00       	mov    $0x2,%eax
  800978:	e8 8d ff ff ff       	call   80090a <fsipc>
}
  80097d:	c9                   	leave  
  80097e:	c3                   	ret    

0080097f <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  80097f:	55                   	push   %ebp
  800980:	89 e5                	mov    %esp,%ebp
  800982:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  800985:	8b 45 08             	mov    0x8(%ebp),%eax
  800988:	8b 40 0c             	mov    0xc(%eax),%eax
  80098b:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800990:	ba 00 00 00 00       	mov    $0x0,%edx
  800995:	b8 06 00 00 00       	mov    $0x6,%eax
  80099a:	e8 6b ff ff ff       	call   80090a <fsipc>
}
  80099f:	c9                   	leave  
  8009a0:	c3                   	ret    

008009a1 <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  8009a1:	55                   	push   %ebp
  8009a2:	89 e5                	mov    %esp,%ebp
  8009a4:	53                   	push   %ebx
  8009a5:	83 ec 04             	sub    $0x4,%esp
  8009a8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009ab:	8b 45 08             	mov    0x8(%ebp),%eax
  8009ae:	8b 40 0c             	mov    0xc(%eax),%eax
  8009b1:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009b6:	ba 00 00 00 00       	mov    $0x0,%edx
  8009bb:	b8 05 00 00 00       	mov    $0x5,%eax
  8009c0:	e8 45 ff ff ff       	call   80090a <fsipc>
  8009c5:	85 c0                	test   %eax,%eax
  8009c7:	78 2c                	js     8009f5 <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c9:	83 ec 08             	sub    $0x8,%esp
  8009cc:	68 00 50 80 00       	push   $0x805000
  8009d1:	53                   	push   %ebx
  8009d2:	e8 0f 0d 00 00       	call   8016e6 <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d7:	a1 80 50 80 00       	mov    0x805080,%eax
  8009dc:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009e2:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e7:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009ed:	83 c4 10             	add    $0x10,%esp
  8009f0:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009f5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f8:	c9                   	leave  
  8009f9:	c3                   	ret    

008009fa <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009fa:	55                   	push   %ebp
  8009fb:	89 e5                	mov    %esp,%ebp
  8009fd:	83 ec 0c             	sub    $0xc,%esp
  800a00:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  800a03:	8b 55 08             	mov    0x8(%ebp),%edx
  800a06:	8b 52 0c             	mov    0xc(%edx),%edx
  800a09:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a0f:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a14:	50                   	push   %eax
  800a15:	ff 75 0c             	pushl  0xc(%ebp)
  800a18:	68 08 50 80 00       	push   $0x805008
  800a1d:	e8 56 0e 00 00       	call   801878 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a22:	ba 00 00 00 00       	mov    $0x0,%edx
  800a27:	b8 04 00 00 00       	mov    $0x4,%eax
  800a2c:	e8 d9 fe ff ff       	call   80090a <fsipc>
	//panic("devfile_write not implemented");
}
  800a31:	c9                   	leave  
  800a32:	c3                   	ret    

00800a33 <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a33:	55                   	push   %ebp
  800a34:	89 e5                	mov    %esp,%ebp
  800a36:	56                   	push   %esi
  800a37:	53                   	push   %ebx
  800a38:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a3b:	8b 45 08             	mov    0x8(%ebp),%eax
  800a3e:	8b 40 0c             	mov    0xc(%eax),%eax
  800a41:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a46:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a4c:	ba 00 00 00 00       	mov    $0x0,%edx
  800a51:	b8 03 00 00 00       	mov    $0x3,%eax
  800a56:	e8 af fe ff ff       	call   80090a <fsipc>
  800a5b:	89 c3                	mov    %eax,%ebx
  800a5d:	85 c0                	test   %eax,%eax
  800a5f:	78 51                	js     800ab2 <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a61:	39 c6                	cmp    %eax,%esi
  800a63:	73 19                	jae    800a7e <devfile_read+0x4b>
  800a65:	68 b0 1e 80 00       	push   $0x801eb0
  800a6a:	68 b7 1e 80 00       	push   $0x801eb7
  800a6f:	68 80 00 00 00       	push   $0x80
  800a74:	68 cc 1e 80 00       	push   $0x801ecc
  800a79:	e8 c0 05 00 00       	call   80103e <_panic>
	assert(r <= PGSIZE);
  800a7e:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a83:	7e 19                	jle    800a9e <devfile_read+0x6b>
  800a85:	68 d7 1e 80 00       	push   $0x801ed7
  800a8a:	68 b7 1e 80 00       	push   $0x801eb7
  800a8f:	68 81 00 00 00       	push   $0x81
  800a94:	68 cc 1e 80 00       	push   $0x801ecc
  800a99:	e8 a0 05 00 00       	call   80103e <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a9e:	83 ec 04             	sub    $0x4,%esp
  800aa1:	50                   	push   %eax
  800aa2:	68 00 50 80 00       	push   $0x805000
  800aa7:	ff 75 0c             	pushl  0xc(%ebp)
  800aaa:	e8 c9 0d 00 00       	call   801878 <memmove>
	return r;
  800aaf:	83 c4 10             	add    $0x10,%esp
}
  800ab2:	89 d8                	mov    %ebx,%eax
  800ab4:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab7:	5b                   	pop    %ebx
  800ab8:	5e                   	pop    %esi
  800ab9:	5d                   	pop    %ebp
  800aba:	c3                   	ret    

00800abb <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800abb:	55                   	push   %ebp
  800abc:	89 e5                	mov    %esp,%ebp
  800abe:	53                   	push   %ebx
  800abf:	83 ec 20             	sub    $0x20,%esp
  800ac2:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800ac5:	53                   	push   %ebx
  800ac6:	e8 e2 0b 00 00       	call   8016ad <strlen>
  800acb:	83 c4 10             	add    $0x10,%esp
  800ace:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800ad3:	7f 67                	jg     800b3c <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ad5:	83 ec 0c             	sub    $0xc,%esp
  800ad8:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800adb:	50                   	push   %eax
  800adc:	e8 a1 f8 ff ff       	call   800382 <fd_alloc>
  800ae1:	83 c4 10             	add    $0x10,%esp
		return r;
  800ae4:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ae6:	85 c0                	test   %eax,%eax
  800ae8:	78 57                	js     800b41 <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800aea:	83 ec 08             	sub    $0x8,%esp
  800aed:	53                   	push   %ebx
  800aee:	68 00 50 80 00       	push   $0x805000
  800af3:	e8 ee 0b 00 00       	call   8016e6 <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af8:	8b 45 0c             	mov    0xc(%ebp),%eax
  800afb:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800b00:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800b03:	b8 01 00 00 00       	mov    $0x1,%eax
  800b08:	e8 fd fd ff ff       	call   80090a <fsipc>
  800b0d:	89 c3                	mov    %eax,%ebx
  800b0f:	83 c4 10             	add    $0x10,%esp
  800b12:	85 c0                	test   %eax,%eax
  800b14:	79 14                	jns    800b2a <open+0x6f>
		
		fd_close(fd, 0);
  800b16:	83 ec 08             	sub    $0x8,%esp
  800b19:	6a 00                	push   $0x0
  800b1b:	ff 75 f4             	pushl  -0xc(%ebp)
  800b1e:	e8 57 f9 ff ff       	call   80047a <fd_close>
		return r;
  800b23:	83 c4 10             	add    $0x10,%esp
  800b26:	89 da                	mov    %ebx,%edx
  800b28:	eb 17                	jmp    800b41 <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  800b2a:	83 ec 0c             	sub    $0xc,%esp
  800b2d:	ff 75 f4             	pushl  -0xc(%ebp)
  800b30:	e8 26 f8 ff ff       	call   80035b <fd2num>
  800b35:	89 c2                	mov    %eax,%edx
  800b37:	83 c4 10             	add    $0x10,%esp
  800b3a:	eb 05                	jmp    800b41 <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b3c:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  800b41:	89 d0                	mov    %edx,%eax
  800b43:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b46:	c9                   	leave  
  800b47:	c3                   	ret    

00800b48 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b48:	55                   	push   %ebp
  800b49:	89 e5                	mov    %esp,%ebp
  800b4b:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b4e:	ba 00 00 00 00       	mov    $0x0,%edx
  800b53:	b8 08 00 00 00       	mov    $0x8,%eax
  800b58:	e8 ad fd ff ff       	call   80090a <fsipc>
}
  800b5d:	c9                   	leave  
  800b5e:	c3                   	ret    

00800b5f <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b5f:	55                   	push   %ebp
  800b60:	89 e5                	mov    %esp,%ebp
  800b62:	56                   	push   %esi
  800b63:	53                   	push   %ebx
  800b64:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b67:	83 ec 0c             	sub    $0xc,%esp
  800b6a:	ff 75 08             	pushl  0x8(%ebp)
  800b6d:	e8 f9 f7 ff ff       	call   80036b <fd2data>
  800b72:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b74:	83 c4 08             	add    $0x8,%esp
  800b77:	68 e3 1e 80 00       	push   $0x801ee3
  800b7c:	53                   	push   %ebx
  800b7d:	e8 64 0b 00 00       	call   8016e6 <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b82:	8b 46 04             	mov    0x4(%esi),%eax
  800b85:	2b 06                	sub    (%esi),%eax
  800b87:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b8d:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b94:	00 00 00 
	stat->st_dev = &devpipe;
  800b97:	c7 83 88 00 00 00 24 	movl   $0x803024,0x88(%ebx)
  800b9e:	30 80 00 
	return 0;
}
  800ba1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ba6:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba9:	5b                   	pop    %ebx
  800baa:	5e                   	pop    %esi
  800bab:	5d                   	pop    %ebp
  800bac:	c3                   	ret    

00800bad <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800bad:	55                   	push   %ebp
  800bae:	89 e5                	mov    %esp,%ebp
  800bb0:	53                   	push   %ebx
  800bb1:	83 ec 0c             	sub    $0xc,%esp
  800bb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb7:	53                   	push   %ebx
  800bb8:	6a 00                	push   $0x0
  800bba:	e8 30 f6 ff ff       	call   8001ef <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bbf:	89 1c 24             	mov    %ebx,(%esp)
  800bc2:	e8 a4 f7 ff ff       	call   80036b <fd2data>
  800bc7:	83 c4 08             	add    $0x8,%esp
  800bca:	50                   	push   %eax
  800bcb:	6a 00                	push   $0x0
  800bcd:	e8 1d f6 ff ff       	call   8001ef <sys_page_unmap>
}
  800bd2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bd5:	c9                   	leave  
  800bd6:	c3                   	ret    

00800bd7 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bd7:	55                   	push   %ebp
  800bd8:	89 e5                	mov    %esp,%ebp
  800bda:	57                   	push   %edi
  800bdb:	56                   	push   %esi
  800bdc:	53                   	push   %ebx
  800bdd:	83 ec 1c             	sub    $0x1c,%esp
  800be0:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800be3:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800be5:	a1 04 40 80 00       	mov    0x804004,%eax
  800bea:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800bed:	83 ec 0c             	sub    $0xc,%esp
  800bf0:	ff 75 e0             	pushl  -0x20(%ebp)
  800bf3:	e8 0e 0f 00 00       	call   801b06 <pageref>
  800bf8:	89 c3                	mov    %eax,%ebx
  800bfa:	89 3c 24             	mov    %edi,(%esp)
  800bfd:	e8 04 0f 00 00       	call   801b06 <pageref>
  800c02:	83 c4 10             	add    $0x10,%esp
  800c05:	39 c3                	cmp    %eax,%ebx
  800c07:	0f 94 c1             	sete   %cl
  800c0a:	0f b6 c9             	movzbl %cl,%ecx
  800c0d:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c10:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c16:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c19:	39 ce                	cmp    %ecx,%esi
  800c1b:	74 1b                	je     800c38 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c1d:	39 c3                	cmp    %eax,%ebx
  800c1f:	75 c4                	jne    800be5 <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c21:	8b 42 58             	mov    0x58(%edx),%eax
  800c24:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c27:	50                   	push   %eax
  800c28:	56                   	push   %esi
  800c29:	68 ea 1e 80 00       	push   $0x801eea
  800c2e:	e8 e4 04 00 00       	call   801117 <cprintf>
  800c33:	83 c4 10             	add    $0x10,%esp
  800c36:	eb ad                	jmp    800be5 <_pipeisclosed+0xe>
	}
}
  800c38:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c3b:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c3e:	5b                   	pop    %ebx
  800c3f:	5e                   	pop    %esi
  800c40:	5f                   	pop    %edi
  800c41:	5d                   	pop    %ebp
  800c42:	c3                   	ret    

00800c43 <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c43:	55                   	push   %ebp
  800c44:	89 e5                	mov    %esp,%ebp
  800c46:	57                   	push   %edi
  800c47:	56                   	push   %esi
  800c48:	53                   	push   %ebx
  800c49:	83 ec 28             	sub    $0x28,%esp
  800c4c:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c4f:	56                   	push   %esi
  800c50:	e8 16 f7 ff ff       	call   80036b <fd2data>
  800c55:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c57:	83 c4 10             	add    $0x10,%esp
  800c5a:	bf 00 00 00 00       	mov    $0x0,%edi
  800c5f:	eb 4b                	jmp    800cac <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c61:	89 da                	mov    %ebx,%edx
  800c63:	89 f0                	mov    %esi,%eax
  800c65:	e8 6d ff ff ff       	call   800bd7 <_pipeisclosed>
  800c6a:	85 c0                	test   %eax,%eax
  800c6c:	75 48                	jne    800cb6 <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c6e:	e8 d8 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c73:	8b 43 04             	mov    0x4(%ebx),%eax
  800c76:	8b 0b                	mov    (%ebx),%ecx
  800c78:	8d 51 20             	lea    0x20(%ecx),%edx
  800c7b:	39 d0                	cmp    %edx,%eax
  800c7d:	73 e2                	jae    800c61 <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c7f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c82:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c86:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c89:	89 c2                	mov    %eax,%edx
  800c8b:	c1 fa 1f             	sar    $0x1f,%edx
  800c8e:	89 d1                	mov    %edx,%ecx
  800c90:	c1 e9 1b             	shr    $0x1b,%ecx
  800c93:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c96:	83 e2 1f             	and    $0x1f,%edx
  800c99:	29 ca                	sub    %ecx,%edx
  800c9b:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c9f:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800ca3:	83 c0 01             	add    $0x1,%eax
  800ca6:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca9:	83 c7 01             	add    $0x1,%edi
  800cac:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800caf:	75 c2                	jne    800c73 <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800cb1:	8b 45 10             	mov    0x10(%ebp),%eax
  800cb4:	eb 05                	jmp    800cbb <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800cb6:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cbb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cbe:	5b                   	pop    %ebx
  800cbf:	5e                   	pop    %esi
  800cc0:	5f                   	pop    %edi
  800cc1:	5d                   	pop    %ebp
  800cc2:	c3                   	ret    

00800cc3 <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cc3:	55                   	push   %ebp
  800cc4:	89 e5                	mov    %esp,%ebp
  800cc6:	57                   	push   %edi
  800cc7:	56                   	push   %esi
  800cc8:	53                   	push   %ebx
  800cc9:	83 ec 18             	sub    $0x18,%esp
  800ccc:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800ccf:	57                   	push   %edi
  800cd0:	e8 96 f6 ff ff       	call   80036b <fd2data>
  800cd5:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd7:	83 c4 10             	add    $0x10,%esp
  800cda:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cdf:	eb 3d                	jmp    800d1e <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800ce1:	85 db                	test   %ebx,%ebx
  800ce3:	74 04                	je     800ce9 <devpipe_read+0x26>
				return i;
  800ce5:	89 d8                	mov    %ebx,%eax
  800ce7:	eb 44                	jmp    800d2d <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ce9:	89 f2                	mov    %esi,%edx
  800ceb:	89 f8                	mov    %edi,%eax
  800ced:	e8 e5 fe ff ff       	call   800bd7 <_pipeisclosed>
  800cf2:	85 c0                	test   %eax,%eax
  800cf4:	75 32                	jne    800d28 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cf6:	e8 50 f4 ff ff       	call   80014b <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cfb:	8b 06                	mov    (%esi),%eax
  800cfd:	3b 46 04             	cmp    0x4(%esi),%eax
  800d00:	74 df                	je     800ce1 <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800d02:	99                   	cltd   
  800d03:	c1 ea 1b             	shr    $0x1b,%edx
  800d06:	01 d0                	add    %edx,%eax
  800d08:	83 e0 1f             	and    $0x1f,%eax
  800d0b:	29 d0                	sub    %edx,%eax
  800d0d:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d12:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d15:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d18:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d1b:	83 c3 01             	add    $0x1,%ebx
  800d1e:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d21:	75 d8                	jne    800cfb <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d23:	8b 45 10             	mov    0x10(%ebp),%eax
  800d26:	eb 05                	jmp    800d2d <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d28:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d2d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d30:	5b                   	pop    %ebx
  800d31:	5e                   	pop    %esi
  800d32:	5f                   	pop    %edi
  800d33:	5d                   	pop    %ebp
  800d34:	c3                   	ret    

00800d35 <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d35:	55                   	push   %ebp
  800d36:	89 e5                	mov    %esp,%ebp
  800d38:	56                   	push   %esi
  800d39:	53                   	push   %ebx
  800d3a:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d3d:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d40:	50                   	push   %eax
  800d41:	e8 3c f6 ff ff       	call   800382 <fd_alloc>
  800d46:	83 c4 10             	add    $0x10,%esp
  800d49:	89 c2                	mov    %eax,%edx
  800d4b:	85 c0                	test   %eax,%eax
  800d4d:	0f 88 2c 01 00 00    	js     800e7f <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d53:	83 ec 04             	sub    $0x4,%esp
  800d56:	68 07 04 00 00       	push   $0x407
  800d5b:	ff 75 f4             	pushl  -0xc(%ebp)
  800d5e:	6a 00                	push   $0x0
  800d60:	e8 05 f4 ff ff       	call   80016a <sys_page_alloc>
  800d65:	83 c4 10             	add    $0x10,%esp
  800d68:	89 c2                	mov    %eax,%edx
  800d6a:	85 c0                	test   %eax,%eax
  800d6c:	0f 88 0d 01 00 00    	js     800e7f <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d72:	83 ec 0c             	sub    $0xc,%esp
  800d75:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d78:	50                   	push   %eax
  800d79:	e8 04 f6 ff ff       	call   800382 <fd_alloc>
  800d7e:	89 c3                	mov    %eax,%ebx
  800d80:	83 c4 10             	add    $0x10,%esp
  800d83:	85 c0                	test   %eax,%eax
  800d85:	0f 88 e2 00 00 00    	js     800e6d <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d8b:	83 ec 04             	sub    $0x4,%esp
  800d8e:	68 07 04 00 00       	push   $0x407
  800d93:	ff 75 f0             	pushl  -0x10(%ebp)
  800d96:	6a 00                	push   $0x0
  800d98:	e8 cd f3 ff ff       	call   80016a <sys_page_alloc>
  800d9d:	89 c3                	mov    %eax,%ebx
  800d9f:	83 c4 10             	add    $0x10,%esp
  800da2:	85 c0                	test   %eax,%eax
  800da4:	0f 88 c3 00 00 00    	js     800e6d <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800daa:	83 ec 0c             	sub    $0xc,%esp
  800dad:	ff 75 f4             	pushl  -0xc(%ebp)
  800db0:	e8 b6 f5 ff ff       	call   80036b <fd2data>
  800db5:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db7:	83 c4 0c             	add    $0xc,%esp
  800dba:	68 07 04 00 00       	push   $0x407
  800dbf:	50                   	push   %eax
  800dc0:	6a 00                	push   $0x0
  800dc2:	e8 a3 f3 ff ff       	call   80016a <sys_page_alloc>
  800dc7:	89 c3                	mov    %eax,%ebx
  800dc9:	83 c4 10             	add    $0x10,%esp
  800dcc:	85 c0                	test   %eax,%eax
  800dce:	0f 88 89 00 00 00    	js     800e5d <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dd4:	83 ec 0c             	sub    $0xc,%esp
  800dd7:	ff 75 f0             	pushl  -0x10(%ebp)
  800dda:	e8 8c f5 ff ff       	call   80036b <fd2data>
  800ddf:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800de6:	50                   	push   %eax
  800de7:	6a 00                	push   $0x0
  800de9:	56                   	push   %esi
  800dea:	6a 00                	push   $0x0
  800dec:	e8 bc f3 ff ff       	call   8001ad <sys_page_map>
  800df1:	89 c3                	mov    %eax,%ebx
  800df3:	83 c4 20             	add    $0x20,%esp
  800df6:	85 c0                	test   %eax,%eax
  800df8:	78 55                	js     800e4f <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800dfa:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e00:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e03:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800e05:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e08:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e0f:	8b 15 24 30 80 00    	mov    0x803024,%edx
  800e15:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e18:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e1a:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e1d:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e24:	83 ec 0c             	sub    $0xc,%esp
  800e27:	ff 75 f4             	pushl  -0xc(%ebp)
  800e2a:	e8 2c f5 ff ff       	call   80035b <fd2num>
  800e2f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e32:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e34:	83 c4 04             	add    $0x4,%esp
  800e37:	ff 75 f0             	pushl  -0x10(%ebp)
  800e3a:	e8 1c f5 ff ff       	call   80035b <fd2num>
  800e3f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e42:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e45:	83 c4 10             	add    $0x10,%esp
  800e48:	ba 00 00 00 00       	mov    $0x0,%edx
  800e4d:	eb 30                	jmp    800e7f <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e4f:	83 ec 08             	sub    $0x8,%esp
  800e52:	56                   	push   %esi
  800e53:	6a 00                	push   $0x0
  800e55:	e8 95 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e5a:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e5d:	83 ec 08             	sub    $0x8,%esp
  800e60:	ff 75 f0             	pushl  -0x10(%ebp)
  800e63:	6a 00                	push   $0x0
  800e65:	e8 85 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e6a:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e6d:	83 ec 08             	sub    $0x8,%esp
  800e70:	ff 75 f4             	pushl  -0xc(%ebp)
  800e73:	6a 00                	push   $0x0
  800e75:	e8 75 f3 ff ff       	call   8001ef <sys_page_unmap>
  800e7a:	83 c4 10             	add    $0x10,%esp
  800e7d:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e7f:	89 d0                	mov    %edx,%eax
  800e81:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e84:	5b                   	pop    %ebx
  800e85:	5e                   	pop    %esi
  800e86:	5d                   	pop    %ebp
  800e87:	c3                   	ret    

00800e88 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e88:	55                   	push   %ebp
  800e89:	89 e5                	mov    %esp,%ebp
  800e8b:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e8e:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e91:	50                   	push   %eax
  800e92:	ff 75 08             	pushl  0x8(%ebp)
  800e95:	e8 37 f5 ff ff       	call   8003d1 <fd_lookup>
  800e9a:	83 c4 10             	add    $0x10,%esp
  800e9d:	85 c0                	test   %eax,%eax
  800e9f:	78 18                	js     800eb9 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800ea1:	83 ec 0c             	sub    $0xc,%esp
  800ea4:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea7:	e8 bf f4 ff ff       	call   80036b <fd2data>
	return _pipeisclosed(fd, p);
  800eac:	89 c2                	mov    %eax,%edx
  800eae:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eb1:	e8 21 fd ff ff       	call   800bd7 <_pipeisclosed>
  800eb6:	83 c4 10             	add    $0x10,%esp
}
  800eb9:	c9                   	leave  
  800eba:	c3                   	ret    

00800ebb <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800ebb:	55                   	push   %ebp
  800ebc:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800ebe:	b8 00 00 00 00       	mov    $0x0,%eax
  800ec3:	5d                   	pop    %ebp
  800ec4:	c3                   	ret    

00800ec5 <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ec5:	55                   	push   %ebp
  800ec6:	89 e5                	mov    %esp,%ebp
  800ec8:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ecb:	68 02 1f 80 00       	push   $0x801f02
  800ed0:	ff 75 0c             	pushl  0xc(%ebp)
  800ed3:	e8 0e 08 00 00       	call   8016e6 <strcpy>
	return 0;
}
  800ed8:	b8 00 00 00 00       	mov    $0x0,%eax
  800edd:	c9                   	leave  
  800ede:	c3                   	ret    

00800edf <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800edf:	55                   	push   %ebp
  800ee0:	89 e5                	mov    %esp,%ebp
  800ee2:	57                   	push   %edi
  800ee3:	56                   	push   %esi
  800ee4:	53                   	push   %ebx
  800ee5:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eeb:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ef0:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ef6:	eb 2d                	jmp    800f25 <devcons_write+0x46>
		m = n - tot;
  800ef8:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800efb:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800efd:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800f00:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800f05:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f08:	83 ec 04             	sub    $0x4,%esp
  800f0b:	53                   	push   %ebx
  800f0c:	03 45 0c             	add    0xc(%ebp),%eax
  800f0f:	50                   	push   %eax
  800f10:	57                   	push   %edi
  800f11:	e8 62 09 00 00       	call   801878 <memmove>
		sys_cputs(buf, m);
  800f16:	83 c4 08             	add    $0x8,%esp
  800f19:	53                   	push   %ebx
  800f1a:	57                   	push   %edi
  800f1b:	e8 8e f1 ff ff       	call   8000ae <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f20:	01 de                	add    %ebx,%esi
  800f22:	83 c4 10             	add    $0x10,%esp
  800f25:	89 f0                	mov    %esi,%eax
  800f27:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f2a:	72 cc                	jb     800ef8 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f2c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f2f:	5b                   	pop    %ebx
  800f30:	5e                   	pop    %esi
  800f31:	5f                   	pop    %edi
  800f32:	5d                   	pop    %ebp
  800f33:	c3                   	ret    

00800f34 <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f34:	55                   	push   %ebp
  800f35:	89 e5                	mov    %esp,%ebp
  800f37:	83 ec 08             	sub    $0x8,%esp
  800f3a:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f3f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f43:	74 2a                	je     800f6f <devcons_read+0x3b>
  800f45:	eb 05                	jmp    800f4c <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f47:	e8 ff f1 ff ff       	call   80014b <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f4c:	e8 7b f1 ff ff       	call   8000cc <sys_cgetc>
  800f51:	85 c0                	test   %eax,%eax
  800f53:	74 f2                	je     800f47 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f55:	85 c0                	test   %eax,%eax
  800f57:	78 16                	js     800f6f <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f59:	83 f8 04             	cmp    $0x4,%eax
  800f5c:	74 0c                	je     800f6a <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f5e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f61:	88 02                	mov    %al,(%edx)
	return 1;
  800f63:	b8 01 00 00 00       	mov    $0x1,%eax
  800f68:	eb 05                	jmp    800f6f <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f6a:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f6f:	c9                   	leave  
  800f70:	c3                   	ret    

00800f71 <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f71:	55                   	push   %ebp
  800f72:	89 e5                	mov    %esp,%ebp
  800f74:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f77:	8b 45 08             	mov    0x8(%ebp),%eax
  800f7a:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f7d:	6a 01                	push   $0x1
  800f7f:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f82:	50                   	push   %eax
  800f83:	e8 26 f1 ff ff       	call   8000ae <sys_cputs>
}
  800f88:	83 c4 10             	add    $0x10,%esp
  800f8b:	c9                   	leave  
  800f8c:	c3                   	ret    

00800f8d <getchar>:

int
getchar(void)
{
  800f8d:	55                   	push   %ebp
  800f8e:	89 e5                	mov    %esp,%ebp
  800f90:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f93:	6a 01                	push   $0x1
  800f95:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f98:	50                   	push   %eax
  800f99:	6a 00                	push   $0x0
  800f9b:	e8 97 f6 ff ff       	call   800637 <read>
	if (r < 0)
  800fa0:	83 c4 10             	add    $0x10,%esp
  800fa3:	85 c0                	test   %eax,%eax
  800fa5:	78 0f                	js     800fb6 <getchar+0x29>
		return r;
	if (r < 1)
  800fa7:	85 c0                	test   %eax,%eax
  800fa9:	7e 06                	jle    800fb1 <getchar+0x24>
		return -E_EOF;
	return c;
  800fab:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800faf:	eb 05                	jmp    800fb6 <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800fb1:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800fb6:	c9                   	leave  
  800fb7:	c3                   	ret    

00800fb8 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb8:	55                   	push   %ebp
  800fb9:	89 e5                	mov    %esp,%ebp
  800fbb:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fbe:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fc1:	50                   	push   %eax
  800fc2:	ff 75 08             	pushl  0x8(%ebp)
  800fc5:	e8 07 f4 ff ff       	call   8003d1 <fd_lookup>
  800fca:	83 c4 10             	add    $0x10,%esp
  800fcd:	85 c0                	test   %eax,%eax
  800fcf:	78 11                	js     800fe2 <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fd1:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fd4:	8b 15 40 30 80 00    	mov    0x803040,%edx
  800fda:	39 10                	cmp    %edx,(%eax)
  800fdc:	0f 94 c0             	sete   %al
  800fdf:	0f b6 c0             	movzbl %al,%eax
}
  800fe2:	c9                   	leave  
  800fe3:	c3                   	ret    

00800fe4 <opencons>:

int
opencons(void)
{
  800fe4:	55                   	push   %ebp
  800fe5:	89 e5                	mov    %esp,%ebp
  800fe7:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fea:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fed:	50                   	push   %eax
  800fee:	e8 8f f3 ff ff       	call   800382 <fd_alloc>
  800ff3:	83 c4 10             	add    $0x10,%esp
		return r;
  800ff6:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff8:	85 c0                	test   %eax,%eax
  800ffa:	78 3e                	js     80103a <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ffc:	83 ec 04             	sub    $0x4,%esp
  800fff:	68 07 04 00 00       	push   $0x407
  801004:	ff 75 f4             	pushl  -0xc(%ebp)
  801007:	6a 00                	push   $0x0
  801009:	e8 5c f1 ff ff       	call   80016a <sys_page_alloc>
  80100e:	83 c4 10             	add    $0x10,%esp
		return r;
  801011:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  801013:	85 c0                	test   %eax,%eax
  801015:	78 23                	js     80103a <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801017:	8b 15 40 30 80 00    	mov    0x803040,%edx
  80101d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801020:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  801022:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801025:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  80102c:	83 ec 0c             	sub    $0xc,%esp
  80102f:	50                   	push   %eax
  801030:	e8 26 f3 ff ff       	call   80035b <fd2num>
  801035:	89 c2                	mov    %eax,%edx
  801037:	83 c4 10             	add    $0x10,%esp
}
  80103a:	89 d0                	mov    %edx,%eax
  80103c:	c9                   	leave  
  80103d:	c3                   	ret    

0080103e <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  80103e:	55                   	push   %ebp
  80103f:	89 e5                	mov    %esp,%ebp
  801041:	56                   	push   %esi
  801042:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  801043:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  801046:	8b 35 04 30 80 00    	mov    0x803004,%esi
  80104c:	e8 db f0 ff ff       	call   80012c <sys_getenvid>
  801051:	83 ec 0c             	sub    $0xc,%esp
  801054:	ff 75 0c             	pushl  0xc(%ebp)
  801057:	ff 75 08             	pushl  0x8(%ebp)
  80105a:	56                   	push   %esi
  80105b:	50                   	push   %eax
  80105c:	68 10 1f 80 00       	push   $0x801f10
  801061:	e8 b1 00 00 00       	call   801117 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  801066:	83 c4 18             	add    $0x18,%esp
  801069:	53                   	push   %ebx
  80106a:	ff 75 10             	pushl  0x10(%ebp)
  80106d:	e8 54 00 00 00       	call   8010c6 <vcprintf>
	cprintf("\n");
  801072:	c7 04 24 fb 1e 80 00 	movl   $0x801efb,(%esp)
  801079:	e8 99 00 00 00       	call   801117 <cprintf>
  80107e:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  801081:	cc                   	int3   
  801082:	eb fd                	jmp    801081 <_panic+0x43>

00801084 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  801084:	55                   	push   %ebp
  801085:	89 e5                	mov    %esp,%ebp
  801087:	53                   	push   %ebx
  801088:	83 ec 04             	sub    $0x4,%esp
  80108b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  80108e:	8b 13                	mov    (%ebx),%edx
  801090:	8d 42 01             	lea    0x1(%edx),%eax
  801093:	89 03                	mov    %eax,(%ebx)
  801095:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801098:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80109c:	3d ff 00 00 00       	cmp    $0xff,%eax
  8010a1:	75 1a                	jne    8010bd <putch+0x39>
		sys_cputs(b->buf, b->idx);
  8010a3:	83 ec 08             	sub    $0x8,%esp
  8010a6:	68 ff 00 00 00       	push   $0xff
  8010ab:	8d 43 08             	lea    0x8(%ebx),%eax
  8010ae:	50                   	push   %eax
  8010af:	e8 fa ef ff ff       	call   8000ae <sys_cputs>
		b->idx = 0;
  8010b4:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010ba:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010bd:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010c4:	c9                   	leave  
  8010c5:	c3                   	ret    

008010c6 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010c6:	55                   	push   %ebp
  8010c7:	89 e5                	mov    %esp,%ebp
  8010c9:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8010cf:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010d6:	00 00 00 
	b.cnt = 0;
  8010d9:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010e0:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010e3:	ff 75 0c             	pushl  0xc(%ebp)
  8010e6:	ff 75 08             	pushl  0x8(%ebp)
  8010e9:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010ef:	50                   	push   %eax
  8010f0:	68 84 10 80 00       	push   $0x801084
  8010f5:	e8 54 01 00 00       	call   80124e <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010fa:	83 c4 08             	add    $0x8,%esp
  8010fd:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  801103:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801109:	50                   	push   %eax
  80110a:	e8 9f ef ff ff       	call   8000ae <sys_cputs>

	return b.cnt;
}
  80110f:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  801115:	c9                   	leave  
  801116:	c3                   	ret    

00801117 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801117:	55                   	push   %ebp
  801118:	89 e5                	mov    %esp,%ebp
  80111a:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  80111d:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801120:	50                   	push   %eax
  801121:	ff 75 08             	pushl  0x8(%ebp)
  801124:	e8 9d ff ff ff       	call   8010c6 <vcprintf>
	va_end(ap);

	return cnt;
}
  801129:	c9                   	leave  
  80112a:	c3                   	ret    

0080112b <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  80112b:	55                   	push   %ebp
  80112c:	89 e5                	mov    %esp,%ebp
  80112e:	57                   	push   %edi
  80112f:	56                   	push   %esi
  801130:	53                   	push   %ebx
  801131:	83 ec 1c             	sub    $0x1c,%esp
  801134:	89 c7                	mov    %eax,%edi
  801136:	89 d6                	mov    %edx,%esi
  801138:	8b 45 08             	mov    0x8(%ebp),%eax
  80113b:	8b 55 0c             	mov    0xc(%ebp),%edx
  80113e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801141:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  801144:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801147:	bb 00 00 00 00       	mov    $0x0,%ebx
  80114c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  80114f:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  801152:	39 d3                	cmp    %edx,%ebx
  801154:	72 05                	jb     80115b <printnum+0x30>
  801156:	39 45 10             	cmp    %eax,0x10(%ebp)
  801159:	77 45                	ja     8011a0 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80115b:	83 ec 0c             	sub    $0xc,%esp
  80115e:	ff 75 18             	pushl  0x18(%ebp)
  801161:	8b 45 14             	mov    0x14(%ebp),%eax
  801164:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801167:	53                   	push   %ebx
  801168:	ff 75 10             	pushl  0x10(%ebp)
  80116b:	83 ec 08             	sub    $0x8,%esp
  80116e:	ff 75 e4             	pushl  -0x1c(%ebp)
  801171:	ff 75 e0             	pushl  -0x20(%ebp)
  801174:	ff 75 dc             	pushl  -0x24(%ebp)
  801177:	ff 75 d8             	pushl  -0x28(%ebp)
  80117a:	e8 d1 09 00 00       	call   801b50 <__udivdi3>
  80117f:	83 c4 18             	add    $0x18,%esp
  801182:	52                   	push   %edx
  801183:	50                   	push   %eax
  801184:	89 f2                	mov    %esi,%edx
  801186:	89 f8                	mov    %edi,%eax
  801188:	e8 9e ff ff ff       	call   80112b <printnum>
  80118d:	83 c4 20             	add    $0x20,%esp
  801190:	eb 18                	jmp    8011aa <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  801192:	83 ec 08             	sub    $0x8,%esp
  801195:	56                   	push   %esi
  801196:	ff 75 18             	pushl  0x18(%ebp)
  801199:	ff d7                	call   *%edi
  80119b:	83 c4 10             	add    $0x10,%esp
  80119e:	eb 03                	jmp    8011a3 <printnum+0x78>
  8011a0:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  8011a3:	83 eb 01             	sub    $0x1,%ebx
  8011a6:	85 db                	test   %ebx,%ebx
  8011a8:	7f e8                	jg     801192 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011aa:	83 ec 08             	sub    $0x8,%esp
  8011ad:	56                   	push   %esi
  8011ae:	83 ec 04             	sub    $0x4,%esp
  8011b1:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011b4:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b7:	ff 75 dc             	pushl  -0x24(%ebp)
  8011ba:	ff 75 d8             	pushl  -0x28(%ebp)
  8011bd:	e8 be 0a 00 00       	call   801c80 <__umoddi3>
  8011c2:	83 c4 14             	add    $0x14,%esp
  8011c5:	0f be 80 33 1f 80 00 	movsbl 0x801f33(%eax),%eax
  8011cc:	50                   	push   %eax
  8011cd:	ff d7                	call   *%edi
}
  8011cf:	83 c4 10             	add    $0x10,%esp
  8011d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011d5:	5b                   	pop    %ebx
  8011d6:	5e                   	pop    %esi
  8011d7:	5f                   	pop    %edi
  8011d8:	5d                   	pop    %ebp
  8011d9:	c3                   	ret    

008011da <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011da:	55                   	push   %ebp
  8011db:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011dd:	83 fa 01             	cmp    $0x1,%edx
  8011e0:	7e 0e                	jle    8011f0 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011e2:	8b 10                	mov    (%eax),%edx
  8011e4:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011e7:	89 08                	mov    %ecx,(%eax)
  8011e9:	8b 02                	mov    (%edx),%eax
  8011eb:	8b 52 04             	mov    0x4(%edx),%edx
  8011ee:	eb 22                	jmp    801212 <getuint+0x38>
	else if (lflag)
  8011f0:	85 d2                	test   %edx,%edx
  8011f2:	74 10                	je     801204 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011f4:	8b 10                	mov    (%eax),%edx
  8011f6:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f9:	89 08                	mov    %ecx,(%eax)
  8011fb:	8b 02                	mov    (%edx),%eax
  8011fd:	ba 00 00 00 00       	mov    $0x0,%edx
  801202:	eb 0e                	jmp    801212 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  801204:	8b 10                	mov    (%eax),%edx
  801206:	8d 4a 04             	lea    0x4(%edx),%ecx
  801209:	89 08                	mov    %ecx,(%eax)
  80120b:	8b 02                	mov    (%edx),%eax
  80120d:	ba 00 00 00 00       	mov    $0x0,%edx
}
  801212:	5d                   	pop    %ebp
  801213:	c3                   	ret    

00801214 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  801214:	55                   	push   %ebp
  801215:	89 e5                	mov    %esp,%ebp
  801217:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  80121a:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  80121e:	8b 10                	mov    (%eax),%edx
  801220:	3b 50 04             	cmp    0x4(%eax),%edx
  801223:	73 0a                	jae    80122f <sprintputch+0x1b>
		*b->buf++ = ch;
  801225:	8d 4a 01             	lea    0x1(%edx),%ecx
  801228:	89 08                	mov    %ecx,(%eax)
  80122a:	8b 45 08             	mov    0x8(%ebp),%eax
  80122d:	88 02                	mov    %al,(%edx)
}
  80122f:	5d                   	pop    %ebp
  801230:	c3                   	ret    

00801231 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  801231:	55                   	push   %ebp
  801232:	89 e5                	mov    %esp,%ebp
  801234:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801237:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80123a:	50                   	push   %eax
  80123b:	ff 75 10             	pushl  0x10(%ebp)
  80123e:	ff 75 0c             	pushl  0xc(%ebp)
  801241:	ff 75 08             	pushl  0x8(%ebp)
  801244:	e8 05 00 00 00       	call   80124e <vprintfmt>
	va_end(ap);
}
  801249:	83 c4 10             	add    $0x10,%esp
  80124c:	c9                   	leave  
  80124d:	c3                   	ret    

0080124e <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  80124e:	55                   	push   %ebp
  80124f:	89 e5                	mov    %esp,%ebp
  801251:	57                   	push   %edi
  801252:	56                   	push   %esi
  801253:	53                   	push   %ebx
  801254:	83 ec 2c             	sub    $0x2c,%esp
  801257:	8b 75 08             	mov    0x8(%ebp),%esi
  80125a:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80125d:	8b 7d 10             	mov    0x10(%ebp),%edi
  801260:	eb 12                	jmp    801274 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  801262:	85 c0                	test   %eax,%eax
  801264:	0f 84 d3 03 00 00    	je     80163d <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80126a:	83 ec 08             	sub    $0x8,%esp
  80126d:	53                   	push   %ebx
  80126e:	50                   	push   %eax
  80126f:	ff d6                	call   *%esi
  801271:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  801274:	83 c7 01             	add    $0x1,%edi
  801277:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80127b:	83 f8 25             	cmp    $0x25,%eax
  80127e:	75 e2                	jne    801262 <vprintfmt+0x14>
  801280:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  801284:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80128b:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801292:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801299:	ba 00 00 00 00       	mov    $0x0,%edx
  80129e:	eb 07                	jmp    8012a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  8012a3:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a7:	8d 47 01             	lea    0x1(%edi),%eax
  8012aa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012ad:	0f b6 07             	movzbl (%edi),%eax
  8012b0:	0f b6 c8             	movzbl %al,%ecx
  8012b3:	83 e8 23             	sub    $0x23,%eax
  8012b6:	3c 55                	cmp    $0x55,%al
  8012b8:	0f 87 64 03 00 00    	ja     801622 <vprintfmt+0x3d4>
  8012be:	0f b6 c0             	movzbl %al,%eax
  8012c1:	ff 24 85 80 20 80 00 	jmp    *0x802080(,%eax,4)
  8012c8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012cb:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012cf:	eb d6                	jmp    8012a7 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012d1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012d4:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d9:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012dc:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012df:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012e3:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012e6:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012e9:	83 fa 09             	cmp    $0x9,%edx
  8012ec:	77 39                	ja     801327 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012ee:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012f1:	eb e9                	jmp    8012dc <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012f3:	8b 45 14             	mov    0x14(%ebp),%eax
  8012f6:	8d 48 04             	lea    0x4(%eax),%ecx
  8012f9:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012fc:	8b 00                	mov    (%eax),%eax
  8012fe:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801301:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  801304:	eb 27                	jmp    80132d <vprintfmt+0xdf>
  801306:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801309:	85 c0                	test   %eax,%eax
  80130b:	b9 00 00 00 00       	mov    $0x0,%ecx
  801310:	0f 49 c8             	cmovns %eax,%ecx
  801313:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801316:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801319:	eb 8c                	jmp    8012a7 <vprintfmt+0x59>
  80131b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  80131e:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  801325:	eb 80                	jmp    8012a7 <vprintfmt+0x59>
  801327:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  80132a:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  80132d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  801331:	0f 89 70 ff ff ff    	jns    8012a7 <vprintfmt+0x59>
				width = precision, precision = -1;
  801337:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80133a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  80133d:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  801344:	e9 5e ff ff ff       	jmp    8012a7 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801349:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80134c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  80134f:	e9 53 ff ff ff       	jmp    8012a7 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  801354:	8b 45 14             	mov    0x14(%ebp),%eax
  801357:	8d 50 04             	lea    0x4(%eax),%edx
  80135a:	89 55 14             	mov    %edx,0x14(%ebp)
  80135d:	83 ec 08             	sub    $0x8,%esp
  801360:	53                   	push   %ebx
  801361:	ff 30                	pushl  (%eax)
  801363:	ff d6                	call   *%esi
			break;
  801365:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801368:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80136b:	e9 04 ff ff ff       	jmp    801274 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801370:	8b 45 14             	mov    0x14(%ebp),%eax
  801373:	8d 50 04             	lea    0x4(%eax),%edx
  801376:	89 55 14             	mov    %edx,0x14(%ebp)
  801379:	8b 00                	mov    (%eax),%eax
  80137b:	99                   	cltd   
  80137c:	31 d0                	xor    %edx,%eax
  80137e:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801380:	83 f8 0f             	cmp    $0xf,%eax
  801383:	7f 0b                	jg     801390 <vprintfmt+0x142>
  801385:	8b 14 85 e0 21 80 00 	mov    0x8021e0(,%eax,4),%edx
  80138c:	85 d2                	test   %edx,%edx
  80138e:	75 18                	jne    8013a8 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801390:	50                   	push   %eax
  801391:	68 4b 1f 80 00       	push   $0x801f4b
  801396:	53                   	push   %ebx
  801397:	56                   	push   %esi
  801398:	e8 94 fe ff ff       	call   801231 <printfmt>
  80139d:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013a0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  8013a3:	e9 cc fe ff ff       	jmp    801274 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013a8:	52                   	push   %edx
  8013a9:	68 c9 1e 80 00       	push   $0x801ec9
  8013ae:	53                   	push   %ebx
  8013af:	56                   	push   %esi
  8013b0:	e8 7c fe ff ff       	call   801231 <printfmt>
  8013b5:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013bb:	e9 b4 fe ff ff       	jmp    801274 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013c0:	8b 45 14             	mov    0x14(%ebp),%eax
  8013c3:	8d 50 04             	lea    0x4(%eax),%edx
  8013c6:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c9:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013cb:	85 ff                	test   %edi,%edi
  8013cd:	b8 44 1f 80 00       	mov    $0x801f44,%eax
  8013d2:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013d5:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013d9:	0f 8e 94 00 00 00    	jle    801473 <vprintfmt+0x225>
  8013df:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013e3:	0f 84 98 00 00 00    	je     801481 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e9:	83 ec 08             	sub    $0x8,%esp
  8013ec:	ff 75 c8             	pushl  -0x38(%ebp)
  8013ef:	57                   	push   %edi
  8013f0:	e8 d0 02 00 00       	call   8016c5 <strnlen>
  8013f5:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013f8:	29 c1                	sub    %eax,%ecx
  8013fa:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8013fd:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  801400:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  801404:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801407:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  80140a:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  80140c:	eb 0f                	jmp    80141d <vprintfmt+0x1cf>
					putch(padc, putdat);
  80140e:	83 ec 08             	sub    $0x8,%esp
  801411:	53                   	push   %ebx
  801412:	ff 75 e0             	pushl  -0x20(%ebp)
  801415:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801417:	83 ef 01             	sub    $0x1,%edi
  80141a:	83 c4 10             	add    $0x10,%esp
  80141d:	85 ff                	test   %edi,%edi
  80141f:	7f ed                	jg     80140e <vprintfmt+0x1c0>
  801421:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  801424:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801427:	85 c9                	test   %ecx,%ecx
  801429:	b8 00 00 00 00       	mov    $0x0,%eax
  80142e:	0f 49 c1             	cmovns %ecx,%eax
  801431:	29 c1                	sub    %eax,%ecx
  801433:	89 75 08             	mov    %esi,0x8(%ebp)
  801436:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801439:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80143c:	89 cb                	mov    %ecx,%ebx
  80143e:	eb 4d                	jmp    80148d <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801440:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  801444:	74 1b                	je     801461 <vprintfmt+0x213>
  801446:	0f be c0             	movsbl %al,%eax
  801449:	83 e8 20             	sub    $0x20,%eax
  80144c:	83 f8 5e             	cmp    $0x5e,%eax
  80144f:	76 10                	jbe    801461 <vprintfmt+0x213>
					putch('?', putdat);
  801451:	83 ec 08             	sub    $0x8,%esp
  801454:	ff 75 0c             	pushl  0xc(%ebp)
  801457:	6a 3f                	push   $0x3f
  801459:	ff 55 08             	call   *0x8(%ebp)
  80145c:	83 c4 10             	add    $0x10,%esp
  80145f:	eb 0d                	jmp    80146e <vprintfmt+0x220>
				else
					putch(ch, putdat);
  801461:	83 ec 08             	sub    $0x8,%esp
  801464:	ff 75 0c             	pushl  0xc(%ebp)
  801467:	52                   	push   %edx
  801468:	ff 55 08             	call   *0x8(%ebp)
  80146b:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  80146e:	83 eb 01             	sub    $0x1,%ebx
  801471:	eb 1a                	jmp    80148d <vprintfmt+0x23f>
  801473:	89 75 08             	mov    %esi,0x8(%ebp)
  801476:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801479:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80147c:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80147f:	eb 0c                	jmp    80148d <vprintfmt+0x23f>
  801481:	89 75 08             	mov    %esi,0x8(%ebp)
  801484:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801487:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80148a:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  80148d:	83 c7 01             	add    $0x1,%edi
  801490:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801494:	0f be d0             	movsbl %al,%edx
  801497:	85 d2                	test   %edx,%edx
  801499:	74 23                	je     8014be <vprintfmt+0x270>
  80149b:	85 f6                	test   %esi,%esi
  80149d:	78 a1                	js     801440 <vprintfmt+0x1f2>
  80149f:	83 ee 01             	sub    $0x1,%esi
  8014a2:	79 9c                	jns    801440 <vprintfmt+0x1f2>
  8014a4:	89 df                	mov    %ebx,%edi
  8014a6:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014ac:	eb 18                	jmp    8014c6 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014ae:	83 ec 08             	sub    $0x8,%esp
  8014b1:	53                   	push   %ebx
  8014b2:	6a 20                	push   $0x20
  8014b4:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014b6:	83 ef 01             	sub    $0x1,%edi
  8014b9:	83 c4 10             	add    $0x10,%esp
  8014bc:	eb 08                	jmp    8014c6 <vprintfmt+0x278>
  8014be:	89 df                	mov    %ebx,%edi
  8014c0:	8b 75 08             	mov    0x8(%ebp),%esi
  8014c3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014c6:	85 ff                	test   %edi,%edi
  8014c8:	7f e4                	jg     8014ae <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014cd:	e9 a2 fd ff ff       	jmp    801274 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014d2:	83 fa 01             	cmp    $0x1,%edx
  8014d5:	7e 16                	jle    8014ed <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014d7:	8b 45 14             	mov    0x14(%ebp),%eax
  8014da:	8d 50 08             	lea    0x8(%eax),%edx
  8014dd:	89 55 14             	mov    %edx,0x14(%ebp)
  8014e0:	8b 50 04             	mov    0x4(%eax),%edx
  8014e3:	8b 00                	mov    (%eax),%eax
  8014e5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8014e8:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8014eb:	eb 32                	jmp    80151f <vprintfmt+0x2d1>
	else if (lflag)
  8014ed:	85 d2                	test   %edx,%edx
  8014ef:	74 18                	je     801509 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014f1:	8b 45 14             	mov    0x14(%ebp),%eax
  8014f4:	8d 50 04             	lea    0x4(%eax),%edx
  8014f7:	89 55 14             	mov    %edx,0x14(%ebp)
  8014fa:	8b 00                	mov    (%eax),%eax
  8014fc:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8014ff:	89 c1                	mov    %eax,%ecx
  801501:	c1 f9 1f             	sar    $0x1f,%ecx
  801504:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801507:	eb 16                	jmp    80151f <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801509:	8b 45 14             	mov    0x14(%ebp),%eax
  80150c:	8d 50 04             	lea    0x4(%eax),%edx
  80150f:	89 55 14             	mov    %edx,0x14(%ebp)
  801512:	8b 00                	mov    (%eax),%eax
  801514:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801517:	89 c1                	mov    %eax,%ecx
  801519:	c1 f9 1f             	sar    $0x1f,%ecx
  80151c:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  80151f:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801522:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801525:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801528:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  80152b:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801530:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  801534:	0f 89 b0 00 00 00    	jns    8015ea <vprintfmt+0x39c>
				putch('-', putdat);
  80153a:	83 ec 08             	sub    $0x8,%esp
  80153d:	53                   	push   %ebx
  80153e:	6a 2d                	push   $0x2d
  801540:	ff d6                	call   *%esi
				num = -(long long) num;
  801542:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801545:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801548:	f7 d8                	neg    %eax
  80154a:	83 d2 00             	adc    $0x0,%edx
  80154d:	f7 da                	neg    %edx
  80154f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801552:	89 55 dc             	mov    %edx,-0x24(%ebp)
  801555:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801558:	b8 0a 00 00 00       	mov    $0xa,%eax
  80155d:	e9 88 00 00 00       	jmp    8015ea <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  801562:	8d 45 14             	lea    0x14(%ebp),%eax
  801565:	e8 70 fc ff ff       	call   8011da <getuint>
  80156a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80156d:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  801570:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  801575:	eb 73                	jmp    8015ea <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  801577:	8d 45 14             	lea    0x14(%ebp),%eax
  80157a:	e8 5b fc ff ff       	call   8011da <getuint>
  80157f:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801582:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  801585:	83 ec 08             	sub    $0x8,%esp
  801588:	53                   	push   %ebx
  801589:	6a 58                	push   $0x58
  80158b:	ff d6                	call   *%esi
			putch('X', putdat);
  80158d:	83 c4 08             	add    $0x8,%esp
  801590:	53                   	push   %ebx
  801591:	6a 58                	push   $0x58
  801593:	ff d6                	call   *%esi
			putch('X', putdat);
  801595:	83 c4 08             	add    $0x8,%esp
  801598:	53                   	push   %ebx
  801599:	6a 58                	push   $0x58
  80159b:	ff d6                	call   *%esi
			goto number;
  80159d:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  8015a0:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  8015a5:	eb 43                	jmp    8015ea <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015a7:	83 ec 08             	sub    $0x8,%esp
  8015aa:	53                   	push   %ebx
  8015ab:	6a 30                	push   $0x30
  8015ad:	ff d6                	call   *%esi
			putch('x', putdat);
  8015af:	83 c4 08             	add    $0x8,%esp
  8015b2:	53                   	push   %ebx
  8015b3:	6a 78                	push   $0x78
  8015b5:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015b7:	8b 45 14             	mov    0x14(%ebp),%eax
  8015ba:	8d 50 04             	lea    0x4(%eax),%edx
  8015bd:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015c0:	8b 00                	mov    (%eax),%eax
  8015c2:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c7:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015ca:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015cd:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015d0:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015d5:	eb 13                	jmp    8015ea <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015d7:	8d 45 14             	lea    0x14(%ebp),%eax
  8015da:	e8 fb fb ff ff       	call   8011da <getuint>
  8015df:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015e2:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8015e5:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015ea:	83 ec 0c             	sub    $0xc,%esp
  8015ed:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8015f1:	52                   	push   %edx
  8015f2:	ff 75 e0             	pushl  -0x20(%ebp)
  8015f5:	50                   	push   %eax
  8015f6:	ff 75 dc             	pushl  -0x24(%ebp)
  8015f9:	ff 75 d8             	pushl  -0x28(%ebp)
  8015fc:	89 da                	mov    %ebx,%edx
  8015fe:	89 f0                	mov    %esi,%eax
  801600:	e8 26 fb ff ff       	call   80112b <printnum>
			break;
  801605:	83 c4 20             	add    $0x20,%esp
  801608:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80160b:	e9 64 fc ff ff       	jmp    801274 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801610:	83 ec 08             	sub    $0x8,%esp
  801613:	53                   	push   %ebx
  801614:	51                   	push   %ecx
  801615:	ff d6                	call   *%esi
			break;
  801617:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80161a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  80161d:	e9 52 fc ff ff       	jmp    801274 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  801622:	83 ec 08             	sub    $0x8,%esp
  801625:	53                   	push   %ebx
  801626:	6a 25                	push   $0x25
  801628:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  80162a:	83 c4 10             	add    $0x10,%esp
  80162d:	eb 03                	jmp    801632 <vprintfmt+0x3e4>
  80162f:	83 ef 01             	sub    $0x1,%edi
  801632:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  801636:	75 f7                	jne    80162f <vprintfmt+0x3e1>
  801638:	e9 37 fc ff ff       	jmp    801274 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  80163d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801640:	5b                   	pop    %ebx
  801641:	5e                   	pop    %esi
  801642:	5f                   	pop    %edi
  801643:	5d                   	pop    %ebp
  801644:	c3                   	ret    

00801645 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  801645:	55                   	push   %ebp
  801646:	89 e5                	mov    %esp,%ebp
  801648:	83 ec 18             	sub    $0x18,%esp
  80164b:	8b 45 08             	mov    0x8(%ebp),%eax
  80164e:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  801651:	89 45 ec             	mov    %eax,-0x14(%ebp)
  801654:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801658:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80165b:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  801662:	85 c0                	test   %eax,%eax
  801664:	74 26                	je     80168c <vsnprintf+0x47>
  801666:	85 d2                	test   %edx,%edx
  801668:	7e 22                	jle    80168c <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80166a:	ff 75 14             	pushl  0x14(%ebp)
  80166d:	ff 75 10             	pushl  0x10(%ebp)
  801670:	8d 45 ec             	lea    -0x14(%ebp),%eax
  801673:	50                   	push   %eax
  801674:	68 14 12 80 00       	push   $0x801214
  801679:	e8 d0 fb ff ff       	call   80124e <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  80167e:	8b 45 ec             	mov    -0x14(%ebp),%eax
  801681:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  801684:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801687:	83 c4 10             	add    $0x10,%esp
  80168a:	eb 05                	jmp    801691 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80168c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  801691:	c9                   	leave  
  801692:	c3                   	ret    

00801693 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  801693:	55                   	push   %ebp
  801694:	89 e5                	mov    %esp,%ebp
  801696:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801699:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80169c:	50                   	push   %eax
  80169d:	ff 75 10             	pushl  0x10(%ebp)
  8016a0:	ff 75 0c             	pushl  0xc(%ebp)
  8016a3:	ff 75 08             	pushl  0x8(%ebp)
  8016a6:	e8 9a ff ff ff       	call   801645 <vsnprintf>
	va_end(ap);

	return rc;
}
  8016ab:	c9                   	leave  
  8016ac:	c3                   	ret    

008016ad <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016ad:	55                   	push   %ebp
  8016ae:	89 e5                	mov    %esp,%ebp
  8016b0:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b3:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b8:	eb 03                	jmp    8016bd <strlen+0x10>
		n++;
  8016ba:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016bd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016c1:	75 f7                	jne    8016ba <strlen+0xd>
		n++;
	return n;
}
  8016c3:	5d                   	pop    %ebp
  8016c4:	c3                   	ret    

008016c5 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016c5:	55                   	push   %ebp
  8016c6:	89 e5                	mov    %esp,%ebp
  8016c8:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016cb:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016ce:	ba 00 00 00 00       	mov    $0x0,%edx
  8016d3:	eb 03                	jmp    8016d8 <strnlen+0x13>
		n++;
  8016d5:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d8:	39 c2                	cmp    %eax,%edx
  8016da:	74 08                	je     8016e4 <strnlen+0x1f>
  8016dc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016e0:	75 f3                	jne    8016d5 <strnlen+0x10>
  8016e2:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016e4:	5d                   	pop    %ebp
  8016e5:	c3                   	ret    

008016e6 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016e6:	55                   	push   %ebp
  8016e7:	89 e5                	mov    %esp,%ebp
  8016e9:	53                   	push   %ebx
  8016ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8016ed:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016f0:	89 c2                	mov    %eax,%edx
  8016f2:	83 c2 01             	add    $0x1,%edx
  8016f5:	83 c1 01             	add    $0x1,%ecx
  8016f8:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016fc:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016ff:	84 db                	test   %bl,%bl
  801701:	75 ef                	jne    8016f2 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  801703:	5b                   	pop    %ebx
  801704:	5d                   	pop    %ebp
  801705:	c3                   	ret    

00801706 <strcat>:

char *
strcat(char *dst, const char *src)
{
  801706:	55                   	push   %ebp
  801707:	89 e5                	mov    %esp,%ebp
  801709:	53                   	push   %ebx
  80170a:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  80170d:	53                   	push   %ebx
  80170e:	e8 9a ff ff ff       	call   8016ad <strlen>
  801713:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  801716:	ff 75 0c             	pushl  0xc(%ebp)
  801719:	01 d8                	add    %ebx,%eax
  80171b:	50                   	push   %eax
  80171c:	e8 c5 ff ff ff       	call   8016e6 <strcpy>
	return dst;
}
  801721:	89 d8                	mov    %ebx,%eax
  801723:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  801726:	c9                   	leave  
  801727:	c3                   	ret    

00801728 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801728:	55                   	push   %ebp
  801729:	89 e5                	mov    %esp,%ebp
  80172b:	56                   	push   %esi
  80172c:	53                   	push   %ebx
  80172d:	8b 75 08             	mov    0x8(%ebp),%esi
  801730:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801733:	89 f3                	mov    %esi,%ebx
  801735:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801738:	89 f2                	mov    %esi,%edx
  80173a:	eb 0f                	jmp    80174b <strncpy+0x23>
		*dst++ = *src;
  80173c:	83 c2 01             	add    $0x1,%edx
  80173f:	0f b6 01             	movzbl (%ecx),%eax
  801742:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  801745:	80 39 01             	cmpb   $0x1,(%ecx)
  801748:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  80174b:	39 da                	cmp    %ebx,%edx
  80174d:	75 ed                	jne    80173c <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  80174f:	89 f0                	mov    %esi,%eax
  801751:	5b                   	pop    %ebx
  801752:	5e                   	pop    %esi
  801753:	5d                   	pop    %ebp
  801754:	c3                   	ret    

00801755 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  801755:	55                   	push   %ebp
  801756:	89 e5                	mov    %esp,%ebp
  801758:	56                   	push   %esi
  801759:	53                   	push   %ebx
  80175a:	8b 75 08             	mov    0x8(%ebp),%esi
  80175d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801760:	8b 55 10             	mov    0x10(%ebp),%edx
  801763:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  801765:	85 d2                	test   %edx,%edx
  801767:	74 21                	je     80178a <strlcpy+0x35>
  801769:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  80176d:	89 f2                	mov    %esi,%edx
  80176f:	eb 09                	jmp    80177a <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  801771:	83 c2 01             	add    $0x1,%edx
  801774:	83 c1 01             	add    $0x1,%ecx
  801777:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  80177a:	39 c2                	cmp    %eax,%edx
  80177c:	74 09                	je     801787 <strlcpy+0x32>
  80177e:	0f b6 19             	movzbl (%ecx),%ebx
  801781:	84 db                	test   %bl,%bl
  801783:	75 ec                	jne    801771 <strlcpy+0x1c>
  801785:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801787:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  80178a:	29 f0                	sub    %esi,%eax
}
  80178c:	5b                   	pop    %ebx
  80178d:	5e                   	pop    %esi
  80178e:	5d                   	pop    %ebp
  80178f:	c3                   	ret    

00801790 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801790:	55                   	push   %ebp
  801791:	89 e5                	mov    %esp,%ebp
  801793:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801796:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801799:	eb 06                	jmp    8017a1 <strcmp+0x11>
		p++, q++;
  80179b:	83 c1 01             	add    $0x1,%ecx
  80179e:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  8017a1:	0f b6 01             	movzbl (%ecx),%eax
  8017a4:	84 c0                	test   %al,%al
  8017a6:	74 04                	je     8017ac <strcmp+0x1c>
  8017a8:	3a 02                	cmp    (%edx),%al
  8017aa:	74 ef                	je     80179b <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017ac:	0f b6 c0             	movzbl %al,%eax
  8017af:	0f b6 12             	movzbl (%edx),%edx
  8017b2:	29 d0                	sub    %edx,%eax
}
  8017b4:	5d                   	pop    %ebp
  8017b5:	c3                   	ret    

008017b6 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017b6:	55                   	push   %ebp
  8017b7:	89 e5                	mov    %esp,%ebp
  8017b9:	53                   	push   %ebx
  8017ba:	8b 45 08             	mov    0x8(%ebp),%eax
  8017bd:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017c0:	89 c3                	mov    %eax,%ebx
  8017c2:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017c5:	eb 06                	jmp    8017cd <strncmp+0x17>
		n--, p++, q++;
  8017c7:	83 c0 01             	add    $0x1,%eax
  8017ca:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017cd:	39 d8                	cmp    %ebx,%eax
  8017cf:	74 15                	je     8017e6 <strncmp+0x30>
  8017d1:	0f b6 08             	movzbl (%eax),%ecx
  8017d4:	84 c9                	test   %cl,%cl
  8017d6:	74 04                	je     8017dc <strncmp+0x26>
  8017d8:	3a 0a                	cmp    (%edx),%cl
  8017da:	74 eb                	je     8017c7 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017dc:	0f b6 00             	movzbl (%eax),%eax
  8017df:	0f b6 12             	movzbl (%edx),%edx
  8017e2:	29 d0                	sub    %edx,%eax
  8017e4:	eb 05                	jmp    8017eb <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017e6:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017eb:	5b                   	pop    %ebx
  8017ec:	5d                   	pop    %ebp
  8017ed:	c3                   	ret    

008017ee <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017ee:	55                   	push   %ebp
  8017ef:	89 e5                	mov    %esp,%ebp
  8017f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8017f4:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f8:	eb 07                	jmp    801801 <strchr+0x13>
		if (*s == c)
  8017fa:	38 ca                	cmp    %cl,%dl
  8017fc:	74 0f                	je     80180d <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017fe:	83 c0 01             	add    $0x1,%eax
  801801:	0f b6 10             	movzbl (%eax),%edx
  801804:	84 d2                	test   %dl,%dl
  801806:	75 f2                	jne    8017fa <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801808:	b8 00 00 00 00       	mov    $0x0,%eax
}
  80180d:	5d                   	pop    %ebp
  80180e:	c3                   	ret    

0080180f <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  80180f:	55                   	push   %ebp
  801810:	89 e5                	mov    %esp,%ebp
  801812:	8b 45 08             	mov    0x8(%ebp),%eax
  801815:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801819:	eb 03                	jmp    80181e <strfind+0xf>
  80181b:	83 c0 01             	add    $0x1,%eax
  80181e:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  801821:	38 ca                	cmp    %cl,%dl
  801823:	74 04                	je     801829 <strfind+0x1a>
  801825:	84 d2                	test   %dl,%dl
  801827:	75 f2                	jne    80181b <strfind+0xc>
			break;
	return (char *) s;
}
  801829:	5d                   	pop    %ebp
  80182a:	c3                   	ret    

0080182b <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  80182b:	55                   	push   %ebp
  80182c:	89 e5                	mov    %esp,%ebp
  80182e:	57                   	push   %edi
  80182f:	56                   	push   %esi
  801830:	53                   	push   %ebx
  801831:	8b 7d 08             	mov    0x8(%ebp),%edi
  801834:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801837:	85 c9                	test   %ecx,%ecx
  801839:	74 36                	je     801871 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  80183b:	f7 c7 03 00 00 00    	test   $0x3,%edi
  801841:	75 28                	jne    80186b <memset+0x40>
  801843:	f6 c1 03             	test   $0x3,%cl
  801846:	75 23                	jne    80186b <memset+0x40>
		c &= 0xFF;
  801848:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  80184c:	89 d3                	mov    %edx,%ebx
  80184e:	c1 e3 08             	shl    $0x8,%ebx
  801851:	89 d6                	mov    %edx,%esi
  801853:	c1 e6 18             	shl    $0x18,%esi
  801856:	89 d0                	mov    %edx,%eax
  801858:	c1 e0 10             	shl    $0x10,%eax
  80185b:	09 f0                	or     %esi,%eax
  80185d:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  80185f:	89 d8                	mov    %ebx,%eax
  801861:	09 d0                	or     %edx,%eax
  801863:	c1 e9 02             	shr    $0x2,%ecx
  801866:	fc                   	cld    
  801867:	f3 ab                	rep stos %eax,%es:(%edi)
  801869:	eb 06                	jmp    801871 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  80186b:	8b 45 0c             	mov    0xc(%ebp),%eax
  80186e:	fc                   	cld    
  80186f:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  801871:	89 f8                	mov    %edi,%eax
  801873:	5b                   	pop    %ebx
  801874:	5e                   	pop    %esi
  801875:	5f                   	pop    %edi
  801876:	5d                   	pop    %ebp
  801877:	c3                   	ret    

00801878 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801878:	55                   	push   %ebp
  801879:	89 e5                	mov    %esp,%ebp
  80187b:	57                   	push   %edi
  80187c:	56                   	push   %esi
  80187d:	8b 45 08             	mov    0x8(%ebp),%eax
  801880:	8b 75 0c             	mov    0xc(%ebp),%esi
  801883:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  801886:	39 c6                	cmp    %eax,%esi
  801888:	73 35                	jae    8018bf <memmove+0x47>
  80188a:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  80188d:	39 d0                	cmp    %edx,%eax
  80188f:	73 2e                	jae    8018bf <memmove+0x47>
		s += n;
		d += n;
  801891:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  801894:	89 d6                	mov    %edx,%esi
  801896:	09 fe                	or     %edi,%esi
  801898:	f7 c6 03 00 00 00    	test   $0x3,%esi
  80189e:	75 13                	jne    8018b3 <memmove+0x3b>
  8018a0:	f6 c1 03             	test   $0x3,%cl
  8018a3:	75 0e                	jne    8018b3 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  8018a5:	83 ef 04             	sub    $0x4,%edi
  8018a8:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018ab:	c1 e9 02             	shr    $0x2,%ecx
  8018ae:	fd                   	std    
  8018af:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018b1:	eb 09                	jmp    8018bc <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018b3:	83 ef 01             	sub    $0x1,%edi
  8018b6:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018b9:	fd                   	std    
  8018ba:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018bc:	fc                   	cld    
  8018bd:	eb 1d                	jmp    8018dc <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018bf:	89 f2                	mov    %esi,%edx
  8018c1:	09 c2                	or     %eax,%edx
  8018c3:	f6 c2 03             	test   $0x3,%dl
  8018c6:	75 0f                	jne    8018d7 <memmove+0x5f>
  8018c8:	f6 c1 03             	test   $0x3,%cl
  8018cb:	75 0a                	jne    8018d7 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018cd:	c1 e9 02             	shr    $0x2,%ecx
  8018d0:	89 c7                	mov    %eax,%edi
  8018d2:	fc                   	cld    
  8018d3:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018d5:	eb 05                	jmp    8018dc <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d7:	89 c7                	mov    %eax,%edi
  8018d9:	fc                   	cld    
  8018da:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018dc:	5e                   	pop    %esi
  8018dd:	5f                   	pop    %edi
  8018de:	5d                   	pop    %ebp
  8018df:	c3                   	ret    

008018e0 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018e0:	55                   	push   %ebp
  8018e1:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018e3:	ff 75 10             	pushl  0x10(%ebp)
  8018e6:	ff 75 0c             	pushl  0xc(%ebp)
  8018e9:	ff 75 08             	pushl  0x8(%ebp)
  8018ec:	e8 87 ff ff ff       	call   801878 <memmove>
}
  8018f1:	c9                   	leave  
  8018f2:	c3                   	ret    

008018f3 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018f3:	55                   	push   %ebp
  8018f4:	89 e5                	mov    %esp,%ebp
  8018f6:	56                   	push   %esi
  8018f7:	53                   	push   %ebx
  8018f8:	8b 45 08             	mov    0x8(%ebp),%eax
  8018fb:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018fe:	89 c6                	mov    %eax,%esi
  801900:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801903:	eb 1a                	jmp    80191f <memcmp+0x2c>
		if (*s1 != *s2)
  801905:	0f b6 08             	movzbl (%eax),%ecx
  801908:	0f b6 1a             	movzbl (%edx),%ebx
  80190b:	38 d9                	cmp    %bl,%cl
  80190d:	74 0a                	je     801919 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  80190f:	0f b6 c1             	movzbl %cl,%eax
  801912:	0f b6 db             	movzbl %bl,%ebx
  801915:	29 d8                	sub    %ebx,%eax
  801917:	eb 0f                	jmp    801928 <memcmp+0x35>
		s1++, s2++;
  801919:	83 c0 01             	add    $0x1,%eax
  80191c:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  80191f:	39 f0                	cmp    %esi,%eax
  801921:	75 e2                	jne    801905 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  801923:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801928:	5b                   	pop    %ebx
  801929:	5e                   	pop    %esi
  80192a:	5d                   	pop    %ebp
  80192b:	c3                   	ret    

0080192c <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  80192c:	55                   	push   %ebp
  80192d:	89 e5                	mov    %esp,%ebp
  80192f:	53                   	push   %ebx
  801930:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  801933:	89 c1                	mov    %eax,%ecx
  801935:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801938:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80193c:	eb 0a                	jmp    801948 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  80193e:	0f b6 10             	movzbl (%eax),%edx
  801941:	39 da                	cmp    %ebx,%edx
  801943:	74 07                	je     80194c <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801945:	83 c0 01             	add    $0x1,%eax
  801948:	39 c8                	cmp    %ecx,%eax
  80194a:	72 f2                	jb     80193e <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  80194c:	5b                   	pop    %ebx
  80194d:	5d                   	pop    %ebp
  80194e:	c3                   	ret    

0080194f <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  80194f:	55                   	push   %ebp
  801950:	89 e5                	mov    %esp,%ebp
  801952:	57                   	push   %edi
  801953:	56                   	push   %esi
  801954:	53                   	push   %ebx
  801955:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801958:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  80195b:	eb 03                	jmp    801960 <strtol+0x11>
		s++;
  80195d:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801960:	0f b6 01             	movzbl (%ecx),%eax
  801963:	3c 20                	cmp    $0x20,%al
  801965:	74 f6                	je     80195d <strtol+0xe>
  801967:	3c 09                	cmp    $0x9,%al
  801969:	74 f2                	je     80195d <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  80196b:	3c 2b                	cmp    $0x2b,%al
  80196d:	75 0a                	jne    801979 <strtol+0x2a>
		s++;
  80196f:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  801972:	bf 00 00 00 00       	mov    $0x0,%edi
  801977:	eb 11                	jmp    80198a <strtol+0x3b>
  801979:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  80197e:	3c 2d                	cmp    $0x2d,%al
  801980:	75 08                	jne    80198a <strtol+0x3b>
		s++, neg = 1;
  801982:	83 c1 01             	add    $0x1,%ecx
  801985:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  80198a:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801990:	75 15                	jne    8019a7 <strtol+0x58>
  801992:	80 39 30             	cmpb   $0x30,(%ecx)
  801995:	75 10                	jne    8019a7 <strtol+0x58>
  801997:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  80199b:	75 7c                	jne    801a19 <strtol+0xca>
		s += 2, base = 16;
  80199d:	83 c1 02             	add    $0x2,%ecx
  8019a0:	bb 10 00 00 00       	mov    $0x10,%ebx
  8019a5:	eb 16                	jmp    8019bd <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019a7:	85 db                	test   %ebx,%ebx
  8019a9:	75 12                	jne    8019bd <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019ab:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019b0:	80 39 30             	cmpb   $0x30,(%ecx)
  8019b3:	75 08                	jne    8019bd <strtol+0x6e>
		s++, base = 8;
  8019b5:	83 c1 01             	add    $0x1,%ecx
  8019b8:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019bd:	b8 00 00 00 00       	mov    $0x0,%eax
  8019c2:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019c5:	0f b6 11             	movzbl (%ecx),%edx
  8019c8:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019cb:	89 f3                	mov    %esi,%ebx
  8019cd:	80 fb 09             	cmp    $0x9,%bl
  8019d0:	77 08                	ja     8019da <strtol+0x8b>
			dig = *s - '0';
  8019d2:	0f be d2             	movsbl %dl,%edx
  8019d5:	83 ea 30             	sub    $0x30,%edx
  8019d8:	eb 22                	jmp    8019fc <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019da:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019dd:	89 f3                	mov    %esi,%ebx
  8019df:	80 fb 19             	cmp    $0x19,%bl
  8019e2:	77 08                	ja     8019ec <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019e4:	0f be d2             	movsbl %dl,%edx
  8019e7:	83 ea 57             	sub    $0x57,%edx
  8019ea:	eb 10                	jmp    8019fc <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019ec:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019ef:	89 f3                	mov    %esi,%ebx
  8019f1:	80 fb 19             	cmp    $0x19,%bl
  8019f4:	77 16                	ja     801a0c <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019f6:	0f be d2             	movsbl %dl,%edx
  8019f9:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019fc:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019ff:	7d 0b                	jge    801a0c <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  801a01:	83 c1 01             	add    $0x1,%ecx
  801a04:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a08:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a0a:	eb b9                	jmp    8019c5 <strtol+0x76>

	if (endptr)
  801a0c:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a10:	74 0d                	je     801a1f <strtol+0xd0>
		*endptr = (char *) s;
  801a12:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a15:	89 0e                	mov    %ecx,(%esi)
  801a17:	eb 06                	jmp    801a1f <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a19:	85 db                	test   %ebx,%ebx
  801a1b:	74 98                	je     8019b5 <strtol+0x66>
  801a1d:	eb 9e                	jmp    8019bd <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a1f:	89 c2                	mov    %eax,%edx
  801a21:	f7 da                	neg    %edx
  801a23:	85 ff                	test   %edi,%edi
  801a25:	0f 45 c2             	cmovne %edx,%eax
}
  801a28:	5b                   	pop    %ebx
  801a29:	5e                   	pop    %esi
  801a2a:	5f                   	pop    %edi
  801a2b:	5d                   	pop    %ebp
  801a2c:	c3                   	ret    

00801a2d <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a2d:	55                   	push   %ebp
  801a2e:	89 e5                	mov    %esp,%ebp
  801a30:	56                   	push   %esi
  801a31:	53                   	push   %ebx
  801a32:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a35:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801a38:	83 ec 0c             	sub    $0xc,%esp
  801a3b:	ff 75 0c             	pushl  0xc(%ebp)
  801a3e:	e8 d7 e8 ff ff       	call   80031a <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801a43:	83 c4 10             	add    $0x10,%esp
  801a46:	85 f6                	test   %esi,%esi
  801a48:	74 1c                	je     801a66 <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801a4a:	a1 04 40 80 00       	mov    0x804004,%eax
  801a4f:	8b 40 78             	mov    0x78(%eax),%eax
  801a52:	89 06                	mov    %eax,(%esi)
  801a54:	eb 10                	jmp    801a66 <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801a56:	83 ec 0c             	sub    $0xc,%esp
  801a59:	68 40 22 80 00       	push   $0x802240
  801a5e:	e8 b4 f6 ff ff       	call   801117 <cprintf>
  801a63:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801a66:	a1 04 40 80 00       	mov    0x804004,%eax
  801a6b:	8b 50 74             	mov    0x74(%eax),%edx
  801a6e:	85 d2                	test   %edx,%edx
  801a70:	74 e4                	je     801a56 <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801a72:	85 db                	test   %ebx,%ebx
  801a74:	74 05                	je     801a7b <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801a76:	8b 40 74             	mov    0x74(%eax),%eax
  801a79:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a7b:	a1 04 40 80 00       	mov    0x804004,%eax
  801a80:	8b 40 70             	mov    0x70(%eax),%eax

}
  801a83:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a86:	5b                   	pop    %ebx
  801a87:	5e                   	pop    %esi
  801a88:	5d                   	pop    %ebp
  801a89:	c3                   	ret    

00801a8a <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a8a:	55                   	push   %ebp
  801a8b:	89 e5                	mov    %esp,%ebp
  801a8d:	57                   	push   %edi
  801a8e:	56                   	push   %esi
  801a8f:	53                   	push   %ebx
  801a90:	83 ec 0c             	sub    $0xc,%esp
  801a93:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a96:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a99:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801a9c:	85 db                	test   %ebx,%ebx
  801a9e:	75 13                	jne    801ab3 <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801aa0:	6a 00                	push   $0x0
  801aa2:	68 00 00 c0 ee       	push   $0xeec00000
  801aa7:	56                   	push   %esi
  801aa8:	57                   	push   %edi
  801aa9:	e8 49 e8 ff ff       	call   8002f7 <sys_ipc_try_send>
  801aae:	83 c4 10             	add    $0x10,%esp
  801ab1:	eb 0e                	jmp    801ac1 <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801ab3:	ff 75 14             	pushl  0x14(%ebp)
  801ab6:	53                   	push   %ebx
  801ab7:	56                   	push   %esi
  801ab8:	57                   	push   %edi
  801ab9:	e8 39 e8 ff ff       	call   8002f7 <sys_ipc_try_send>
  801abe:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801ac1:	85 c0                	test   %eax,%eax
  801ac3:	75 d7                	jne    801a9c <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801ac5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac8:	5b                   	pop    %ebx
  801ac9:	5e                   	pop    %esi
  801aca:	5f                   	pop    %edi
  801acb:	5d                   	pop    %ebp
  801acc:	c3                   	ret    

00801acd <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801acd:	55                   	push   %ebp
  801ace:	89 e5                	mov    %esp,%ebp
  801ad0:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801ad3:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad8:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801adb:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ae1:	8b 52 50             	mov    0x50(%edx),%edx
  801ae4:	39 ca                	cmp    %ecx,%edx
  801ae6:	75 0d                	jne    801af5 <ipc_find_env+0x28>
			return envs[i].env_id;
  801ae8:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801aeb:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801af0:	8b 40 48             	mov    0x48(%eax),%eax
  801af3:	eb 0f                	jmp    801b04 <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801af5:	83 c0 01             	add    $0x1,%eax
  801af8:	3d 00 04 00 00       	cmp    $0x400,%eax
  801afd:	75 d9                	jne    801ad8 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801aff:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801b04:	5d                   	pop    %ebp
  801b05:	c3                   	ret    

00801b06 <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801b06:	55                   	push   %ebp
  801b07:	89 e5                	mov    %esp,%ebp
  801b09:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b0c:	89 d0                	mov    %edx,%eax
  801b0e:	c1 e8 16             	shr    $0x16,%eax
  801b11:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b18:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b1d:	f6 c1 01             	test   $0x1,%cl
  801b20:	74 1d                	je     801b3f <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b22:	c1 ea 0c             	shr    $0xc,%edx
  801b25:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b2c:	f6 c2 01             	test   $0x1,%dl
  801b2f:	74 0e                	je     801b3f <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b31:	c1 ea 0c             	shr    $0xc,%edx
  801b34:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b3b:	ef 
  801b3c:	0f b7 c0             	movzwl %ax,%eax
}
  801b3f:	5d                   	pop    %ebp
  801b40:	c3                   	ret    
  801b41:	66 90                	xchg   %ax,%ax
  801b43:	66 90                	xchg   %ax,%ax
  801b45:	66 90                	xchg   %ax,%ax
  801b47:	66 90                	xchg   %ax,%ax
  801b49:	66 90                	xchg   %ax,%ax
  801b4b:	66 90                	xchg   %ax,%ax
  801b4d:	66 90                	xchg   %ax,%ax
  801b4f:	90                   	nop

00801b50 <__udivdi3>:
  801b50:	55                   	push   %ebp
  801b51:	57                   	push   %edi
  801b52:	56                   	push   %esi
  801b53:	53                   	push   %ebx
  801b54:	83 ec 1c             	sub    $0x1c,%esp
  801b57:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  801b5b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  801b5f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  801b63:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801b67:	85 f6                	test   %esi,%esi
  801b69:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801b6d:	89 ca                	mov    %ecx,%edx
  801b6f:	89 f8                	mov    %edi,%eax
  801b71:	75 3d                	jne    801bb0 <__udivdi3+0x60>
  801b73:	39 cf                	cmp    %ecx,%edi
  801b75:	0f 87 c5 00 00 00    	ja     801c40 <__udivdi3+0xf0>
  801b7b:	85 ff                	test   %edi,%edi
  801b7d:	89 fd                	mov    %edi,%ebp
  801b7f:	75 0b                	jne    801b8c <__udivdi3+0x3c>
  801b81:	b8 01 00 00 00       	mov    $0x1,%eax
  801b86:	31 d2                	xor    %edx,%edx
  801b88:	f7 f7                	div    %edi
  801b8a:	89 c5                	mov    %eax,%ebp
  801b8c:	89 c8                	mov    %ecx,%eax
  801b8e:	31 d2                	xor    %edx,%edx
  801b90:	f7 f5                	div    %ebp
  801b92:	89 c1                	mov    %eax,%ecx
  801b94:	89 d8                	mov    %ebx,%eax
  801b96:	89 cf                	mov    %ecx,%edi
  801b98:	f7 f5                	div    %ebp
  801b9a:	89 c3                	mov    %eax,%ebx
  801b9c:	89 d8                	mov    %ebx,%eax
  801b9e:	89 fa                	mov    %edi,%edx
  801ba0:	83 c4 1c             	add    $0x1c,%esp
  801ba3:	5b                   	pop    %ebx
  801ba4:	5e                   	pop    %esi
  801ba5:	5f                   	pop    %edi
  801ba6:	5d                   	pop    %ebp
  801ba7:	c3                   	ret    
  801ba8:	90                   	nop
  801ba9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801bb0:	39 ce                	cmp    %ecx,%esi
  801bb2:	77 74                	ja     801c28 <__udivdi3+0xd8>
  801bb4:	0f bd fe             	bsr    %esi,%edi
  801bb7:	83 f7 1f             	xor    $0x1f,%edi
  801bba:	0f 84 98 00 00 00    	je     801c58 <__udivdi3+0x108>
  801bc0:	bb 20 00 00 00       	mov    $0x20,%ebx
  801bc5:	89 f9                	mov    %edi,%ecx
  801bc7:	89 c5                	mov    %eax,%ebp
  801bc9:	29 fb                	sub    %edi,%ebx
  801bcb:	d3 e6                	shl    %cl,%esi
  801bcd:	89 d9                	mov    %ebx,%ecx
  801bcf:	d3 ed                	shr    %cl,%ebp
  801bd1:	89 f9                	mov    %edi,%ecx
  801bd3:	d3 e0                	shl    %cl,%eax
  801bd5:	09 ee                	or     %ebp,%esi
  801bd7:	89 d9                	mov    %ebx,%ecx
  801bd9:	89 44 24 0c          	mov    %eax,0xc(%esp)
  801bdd:	89 d5                	mov    %edx,%ebp
  801bdf:	8b 44 24 08          	mov    0x8(%esp),%eax
  801be3:	d3 ed                	shr    %cl,%ebp
  801be5:	89 f9                	mov    %edi,%ecx
  801be7:	d3 e2                	shl    %cl,%edx
  801be9:	89 d9                	mov    %ebx,%ecx
  801beb:	d3 e8                	shr    %cl,%eax
  801bed:	09 c2                	or     %eax,%edx
  801bef:	89 d0                	mov    %edx,%eax
  801bf1:	89 ea                	mov    %ebp,%edx
  801bf3:	f7 f6                	div    %esi
  801bf5:	89 d5                	mov    %edx,%ebp
  801bf7:	89 c3                	mov    %eax,%ebx
  801bf9:	f7 64 24 0c          	mull   0xc(%esp)
  801bfd:	39 d5                	cmp    %edx,%ebp
  801bff:	72 10                	jb     801c11 <__udivdi3+0xc1>
  801c01:	8b 74 24 08          	mov    0x8(%esp),%esi
  801c05:	89 f9                	mov    %edi,%ecx
  801c07:	d3 e6                	shl    %cl,%esi
  801c09:	39 c6                	cmp    %eax,%esi
  801c0b:	73 07                	jae    801c14 <__udivdi3+0xc4>
  801c0d:	39 d5                	cmp    %edx,%ebp
  801c0f:	75 03                	jne    801c14 <__udivdi3+0xc4>
  801c11:	83 eb 01             	sub    $0x1,%ebx
  801c14:	31 ff                	xor    %edi,%edi
  801c16:	89 d8                	mov    %ebx,%eax
  801c18:	89 fa                	mov    %edi,%edx
  801c1a:	83 c4 1c             	add    $0x1c,%esp
  801c1d:	5b                   	pop    %ebx
  801c1e:	5e                   	pop    %esi
  801c1f:	5f                   	pop    %edi
  801c20:	5d                   	pop    %ebp
  801c21:	c3                   	ret    
  801c22:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801c28:	31 ff                	xor    %edi,%edi
  801c2a:	31 db                	xor    %ebx,%ebx
  801c2c:	89 d8                	mov    %ebx,%eax
  801c2e:	89 fa                	mov    %edi,%edx
  801c30:	83 c4 1c             	add    $0x1c,%esp
  801c33:	5b                   	pop    %ebx
  801c34:	5e                   	pop    %esi
  801c35:	5f                   	pop    %edi
  801c36:	5d                   	pop    %ebp
  801c37:	c3                   	ret    
  801c38:	90                   	nop
  801c39:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801c40:	89 d8                	mov    %ebx,%eax
  801c42:	f7 f7                	div    %edi
  801c44:	31 ff                	xor    %edi,%edi
  801c46:	89 c3                	mov    %eax,%ebx
  801c48:	89 d8                	mov    %ebx,%eax
  801c4a:	89 fa                	mov    %edi,%edx
  801c4c:	83 c4 1c             	add    $0x1c,%esp
  801c4f:	5b                   	pop    %ebx
  801c50:	5e                   	pop    %esi
  801c51:	5f                   	pop    %edi
  801c52:	5d                   	pop    %ebp
  801c53:	c3                   	ret    
  801c54:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801c58:	39 ce                	cmp    %ecx,%esi
  801c5a:	72 0c                	jb     801c68 <__udivdi3+0x118>
  801c5c:	31 db                	xor    %ebx,%ebx
  801c5e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  801c62:	0f 87 34 ff ff ff    	ja     801b9c <__udivdi3+0x4c>
  801c68:	bb 01 00 00 00       	mov    $0x1,%ebx
  801c6d:	e9 2a ff ff ff       	jmp    801b9c <__udivdi3+0x4c>
  801c72:	66 90                	xchg   %ax,%ax
  801c74:	66 90                	xchg   %ax,%ax
  801c76:	66 90                	xchg   %ax,%ax
  801c78:	66 90                	xchg   %ax,%ax
  801c7a:	66 90                	xchg   %ax,%ax
  801c7c:	66 90                	xchg   %ax,%ax
  801c7e:	66 90                	xchg   %ax,%ax

00801c80 <__umoddi3>:
  801c80:	55                   	push   %ebp
  801c81:	57                   	push   %edi
  801c82:	56                   	push   %esi
  801c83:	53                   	push   %ebx
  801c84:	83 ec 1c             	sub    $0x1c,%esp
  801c87:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  801c8b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  801c8f:	8b 74 24 34          	mov    0x34(%esp),%esi
  801c93:	8b 7c 24 38          	mov    0x38(%esp),%edi
  801c97:	85 d2                	test   %edx,%edx
  801c99:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  801c9d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801ca1:	89 f3                	mov    %esi,%ebx
  801ca3:	89 3c 24             	mov    %edi,(%esp)
  801ca6:	89 74 24 04          	mov    %esi,0x4(%esp)
  801caa:	75 1c                	jne    801cc8 <__umoddi3+0x48>
  801cac:	39 f7                	cmp    %esi,%edi
  801cae:	76 50                	jbe    801d00 <__umoddi3+0x80>
  801cb0:	89 c8                	mov    %ecx,%eax
  801cb2:	89 f2                	mov    %esi,%edx
  801cb4:	f7 f7                	div    %edi
  801cb6:	89 d0                	mov    %edx,%eax
  801cb8:	31 d2                	xor    %edx,%edx
  801cba:	83 c4 1c             	add    $0x1c,%esp
  801cbd:	5b                   	pop    %ebx
  801cbe:	5e                   	pop    %esi
  801cbf:	5f                   	pop    %edi
  801cc0:	5d                   	pop    %ebp
  801cc1:	c3                   	ret    
  801cc2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  801cc8:	39 f2                	cmp    %esi,%edx
  801cca:	89 d0                	mov    %edx,%eax
  801ccc:	77 52                	ja     801d20 <__umoddi3+0xa0>
  801cce:	0f bd ea             	bsr    %edx,%ebp
  801cd1:	83 f5 1f             	xor    $0x1f,%ebp
  801cd4:	75 5a                	jne    801d30 <__umoddi3+0xb0>
  801cd6:	3b 54 24 04          	cmp    0x4(%esp),%edx
  801cda:	0f 82 e0 00 00 00    	jb     801dc0 <__umoddi3+0x140>
  801ce0:	39 0c 24             	cmp    %ecx,(%esp)
  801ce3:	0f 86 d7 00 00 00    	jbe    801dc0 <__umoddi3+0x140>
  801ce9:	8b 44 24 08          	mov    0x8(%esp),%eax
  801ced:	8b 54 24 04          	mov    0x4(%esp),%edx
  801cf1:	83 c4 1c             	add    $0x1c,%esp
  801cf4:	5b                   	pop    %ebx
  801cf5:	5e                   	pop    %esi
  801cf6:	5f                   	pop    %edi
  801cf7:	5d                   	pop    %ebp
  801cf8:	c3                   	ret    
  801cf9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  801d00:	85 ff                	test   %edi,%edi
  801d02:	89 fd                	mov    %edi,%ebp
  801d04:	75 0b                	jne    801d11 <__umoddi3+0x91>
  801d06:	b8 01 00 00 00       	mov    $0x1,%eax
  801d0b:	31 d2                	xor    %edx,%edx
  801d0d:	f7 f7                	div    %edi
  801d0f:	89 c5                	mov    %eax,%ebp
  801d11:	89 f0                	mov    %esi,%eax
  801d13:	31 d2                	xor    %edx,%edx
  801d15:	f7 f5                	div    %ebp
  801d17:	89 c8                	mov    %ecx,%eax
  801d19:	f7 f5                	div    %ebp
  801d1b:	89 d0                	mov    %edx,%eax
  801d1d:	eb 99                	jmp    801cb8 <__umoddi3+0x38>
  801d1f:	90                   	nop
  801d20:	89 c8                	mov    %ecx,%eax
  801d22:	89 f2                	mov    %esi,%edx
  801d24:	83 c4 1c             	add    $0x1c,%esp
  801d27:	5b                   	pop    %ebx
  801d28:	5e                   	pop    %esi
  801d29:	5f                   	pop    %edi
  801d2a:	5d                   	pop    %ebp
  801d2b:	c3                   	ret    
  801d2c:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  801d30:	8b 34 24             	mov    (%esp),%esi
  801d33:	bf 20 00 00 00       	mov    $0x20,%edi
  801d38:	89 e9                	mov    %ebp,%ecx
  801d3a:	29 ef                	sub    %ebp,%edi
  801d3c:	d3 e0                	shl    %cl,%eax
  801d3e:	89 f9                	mov    %edi,%ecx
  801d40:	89 f2                	mov    %esi,%edx
  801d42:	d3 ea                	shr    %cl,%edx
  801d44:	89 e9                	mov    %ebp,%ecx
  801d46:	09 c2                	or     %eax,%edx
  801d48:	89 d8                	mov    %ebx,%eax
  801d4a:	89 14 24             	mov    %edx,(%esp)
  801d4d:	89 f2                	mov    %esi,%edx
  801d4f:	d3 e2                	shl    %cl,%edx
  801d51:	89 f9                	mov    %edi,%ecx
  801d53:	89 54 24 04          	mov    %edx,0x4(%esp)
  801d57:	8b 54 24 0c          	mov    0xc(%esp),%edx
  801d5b:	d3 e8                	shr    %cl,%eax
  801d5d:	89 e9                	mov    %ebp,%ecx
  801d5f:	89 c6                	mov    %eax,%esi
  801d61:	d3 e3                	shl    %cl,%ebx
  801d63:	89 f9                	mov    %edi,%ecx
  801d65:	89 d0                	mov    %edx,%eax
  801d67:	d3 e8                	shr    %cl,%eax
  801d69:	89 e9                	mov    %ebp,%ecx
  801d6b:	09 d8                	or     %ebx,%eax
  801d6d:	89 d3                	mov    %edx,%ebx
  801d6f:	89 f2                	mov    %esi,%edx
  801d71:	f7 34 24             	divl   (%esp)
  801d74:	89 d6                	mov    %edx,%esi
  801d76:	d3 e3                	shl    %cl,%ebx
  801d78:	f7 64 24 04          	mull   0x4(%esp)
  801d7c:	39 d6                	cmp    %edx,%esi
  801d7e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  801d82:	89 d1                	mov    %edx,%ecx
  801d84:	89 c3                	mov    %eax,%ebx
  801d86:	72 08                	jb     801d90 <__umoddi3+0x110>
  801d88:	75 11                	jne    801d9b <__umoddi3+0x11b>
  801d8a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  801d8e:	73 0b                	jae    801d9b <__umoddi3+0x11b>
  801d90:	2b 44 24 04          	sub    0x4(%esp),%eax
  801d94:	1b 14 24             	sbb    (%esp),%edx
  801d97:	89 d1                	mov    %edx,%ecx
  801d99:	89 c3                	mov    %eax,%ebx
  801d9b:	8b 54 24 08          	mov    0x8(%esp),%edx
  801d9f:	29 da                	sub    %ebx,%edx
  801da1:	19 ce                	sbb    %ecx,%esi
  801da3:	89 f9                	mov    %edi,%ecx
  801da5:	89 f0                	mov    %esi,%eax
  801da7:	d3 e0                	shl    %cl,%eax
  801da9:	89 e9                	mov    %ebp,%ecx
  801dab:	d3 ea                	shr    %cl,%edx
  801dad:	89 e9                	mov    %ebp,%ecx
  801daf:	d3 ee                	shr    %cl,%esi
  801db1:	09 d0                	or     %edx,%eax
  801db3:	89 f2                	mov    %esi,%edx
  801db5:	83 c4 1c             	add    $0x1c,%esp
  801db8:	5b                   	pop    %ebx
  801db9:	5e                   	pop    %esi
  801dba:	5f                   	pop    %edi
  801dbb:	5d                   	pop    %ebp
  801dbc:	c3                   	ret    
  801dbd:	8d 76 00             	lea    0x0(%esi),%esi
  801dc0:	29 f9                	sub    %edi,%ecx
  801dc2:	19 d6                	sbb    %edx,%esi
  801dc4:	89 74 24 04          	mov    %esi,0x4(%esp)
  801dc8:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  801dcc:	e9 18 ff ff ff       	jmp    801ce9 <__umoddi3+0x69>
