
obj/user/buggyhello2:     file format elf32-i386


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
  80003e:	ff 35 00 20 80 00    	pushl  0x802000
  800044:	e8 5d 00 00 00       	call   8000a6 <sys_cputs>
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
  800059:	e8 c6 00 00 00       	call   800124 <sys_getenvid>
  80005e:	25 ff 03 00 00       	and    $0x3ff,%eax
  800063:	6b c0 7c             	imul   $0x7c,%eax,%eax
  800066:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  80006b:	a3 08 20 80 00       	mov    %eax,0x802008
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800070:	85 db                	test   %ebx,%ebx
  800072:	7e 07                	jle    80007b <libmain+0x2d>
		binaryname = argv[0];
  800074:	8b 06                	mov    (%esi),%eax
  800076:	a3 04 20 80 00       	mov    %eax,0x802004

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
  800097:	83 ec 14             	sub    $0x14,%esp
	sys_env_destroy(0);
  80009a:	6a 00                	push   $0x0
  80009c:	e8 42 00 00 00       	call   8000e3 <sys_env_destroy>
}
  8000a1:	83 c4 10             	add    $0x10,%esp
  8000a4:	c9                   	leave  
  8000a5:	c3                   	ret    

008000a6 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a6:	55                   	push   %ebp
  8000a7:	89 e5                	mov    %esp,%ebp
  8000a9:	57                   	push   %edi
  8000aa:	56                   	push   %esi
  8000ab:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b4:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b7:	89 c3                	mov    %eax,%ebx
  8000b9:	89 c7                	mov    %eax,%edi
  8000bb:	89 c6                	mov    %eax,%esi
  8000bd:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000bf:	5b                   	pop    %ebx
  8000c0:	5e                   	pop    %esi
  8000c1:	5f                   	pop    %edi
  8000c2:	5d                   	pop    %ebp
  8000c3:	c3                   	ret    

008000c4 <sys_cgetc>:

int
sys_cgetc(void)
{
  8000c4:	55                   	push   %ebp
  8000c5:	89 e5                	mov    %esp,%ebp
  8000c7:	57                   	push   %edi
  8000c8:	56                   	push   %esi
  8000c9:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000ca:	ba 00 00 00 00       	mov    $0x0,%edx
  8000cf:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d4:	89 d1                	mov    %edx,%ecx
  8000d6:	89 d3                	mov    %edx,%ebx
  8000d8:	89 d7                	mov    %edx,%edi
  8000da:	89 d6                	mov    %edx,%esi
  8000dc:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000de:	5b                   	pop    %ebx
  8000df:	5e                   	pop    %esi
  8000e0:	5f                   	pop    %edi
  8000e1:	5d                   	pop    %ebp
  8000e2:	c3                   	ret    

008000e3 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e3:	55                   	push   %ebp
  8000e4:	89 e5                	mov    %esp,%ebp
  8000e6:	57                   	push   %edi
  8000e7:	56                   	push   %esi
  8000e8:	53                   	push   %ebx
  8000e9:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000ec:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f1:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f6:	8b 55 08             	mov    0x8(%ebp),%edx
  8000f9:	89 cb                	mov    %ecx,%ebx
  8000fb:	89 cf                	mov    %ecx,%edi
  8000fd:	89 ce                	mov    %ecx,%esi
  8000ff:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800101:	85 c0                	test   %eax,%eax
  800103:	7e 17                	jle    80011c <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800105:	83 ec 0c             	sub    $0xc,%esp
  800108:	50                   	push   %eax
  800109:	6a 03                	push   $0x3
  80010b:	68 b8 0f 80 00       	push   $0x800fb8
  800110:	6a 23                	push   $0x23
  800112:	68 d5 0f 80 00       	push   $0x800fd5
  800117:	e8 f5 01 00 00       	call   800311 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80011f:	5b                   	pop    %ebx
  800120:	5e                   	pop    %esi
  800121:	5f                   	pop    %edi
  800122:	5d                   	pop    %ebp
  800123:	c3                   	ret    

00800124 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800124:	55                   	push   %ebp
  800125:	89 e5                	mov    %esp,%ebp
  800127:	57                   	push   %edi
  800128:	56                   	push   %esi
  800129:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80012a:	ba 00 00 00 00       	mov    $0x0,%edx
  80012f:	b8 02 00 00 00       	mov    $0x2,%eax
  800134:	89 d1                	mov    %edx,%ecx
  800136:	89 d3                	mov    %edx,%ebx
  800138:	89 d7                	mov    %edx,%edi
  80013a:	89 d6                	mov    %edx,%esi
  80013c:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013e:	5b                   	pop    %ebx
  80013f:	5e                   	pop    %esi
  800140:	5f                   	pop    %edi
  800141:	5d                   	pop    %ebp
  800142:	c3                   	ret    

00800143 <sys_yield>:

void
sys_yield(void)
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
  80014e:	b8 0a 00 00 00       	mov    $0xa,%eax
  800153:	89 d1                	mov    %edx,%ecx
  800155:	89 d3                	mov    %edx,%ebx
  800157:	89 d7                	mov    %edx,%edi
  800159:	89 d6                	mov    %edx,%esi
  80015b:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015d:	5b                   	pop    %ebx
  80015e:	5e                   	pop    %esi
  80015f:	5f                   	pop    %edi
  800160:	5d                   	pop    %ebp
  800161:	c3                   	ret    

00800162 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800162:	55                   	push   %ebp
  800163:	89 e5                	mov    %esp,%ebp
  800165:	57                   	push   %edi
  800166:	56                   	push   %esi
  800167:	53                   	push   %ebx
  800168:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80016b:	be 00 00 00 00       	mov    $0x0,%esi
  800170:	b8 04 00 00 00       	mov    $0x4,%eax
  800175:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800178:	8b 55 08             	mov    0x8(%ebp),%edx
  80017b:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017e:	89 f7                	mov    %esi,%edi
  800180:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800182:	85 c0                	test   %eax,%eax
  800184:	7e 17                	jle    80019d <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800186:	83 ec 0c             	sub    $0xc,%esp
  800189:	50                   	push   %eax
  80018a:	6a 04                	push   $0x4
  80018c:	68 b8 0f 80 00       	push   $0x800fb8
  800191:	6a 23                	push   $0x23
  800193:	68 d5 0f 80 00       	push   $0x800fd5
  800198:	e8 74 01 00 00       	call   800311 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a0:	5b                   	pop    %ebx
  8001a1:	5e                   	pop    %esi
  8001a2:	5f                   	pop    %edi
  8001a3:	5d                   	pop    %ebp
  8001a4:	c3                   	ret    

008001a5 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a5:	55                   	push   %ebp
  8001a6:	89 e5                	mov    %esp,%ebp
  8001a8:	57                   	push   %edi
  8001a9:	56                   	push   %esi
  8001aa:	53                   	push   %ebx
  8001ab:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001ae:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b3:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b6:	8b 55 08             	mov    0x8(%ebp),%edx
  8001b9:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bc:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001bf:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c2:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8001c4:	85 c0                	test   %eax,%eax
  8001c6:	7e 17                	jle    8001df <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c8:	83 ec 0c             	sub    $0xc,%esp
  8001cb:	50                   	push   %eax
  8001cc:	6a 05                	push   $0x5
  8001ce:	68 b8 0f 80 00       	push   $0x800fb8
  8001d3:	6a 23                	push   $0x23
  8001d5:	68 d5 0f 80 00       	push   $0x800fd5
  8001da:	e8 32 01 00 00       	call   800311 <_panic>

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001df:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e2:	5b                   	pop    %ebx
  8001e3:	5e                   	pop    %esi
  8001e4:	5f                   	pop    %edi
  8001e5:	5d                   	pop    %ebp
  8001e6:	c3                   	ret    

008001e7 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e7:	55                   	push   %ebp
  8001e8:	89 e5                	mov    %esp,%ebp
  8001ea:	57                   	push   %edi
  8001eb:	56                   	push   %esi
  8001ec:	53                   	push   %ebx
  8001ed:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001f0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f5:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fa:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fd:	8b 55 08             	mov    0x8(%ebp),%edx
  800200:	89 df                	mov    %ebx,%edi
  800202:	89 de                	mov    %ebx,%esi
  800204:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800206:	85 c0                	test   %eax,%eax
  800208:	7e 17                	jle    800221 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020a:	83 ec 0c             	sub    $0xc,%esp
  80020d:	50                   	push   %eax
  80020e:	6a 06                	push   $0x6
  800210:	68 b8 0f 80 00       	push   $0x800fb8
  800215:	6a 23                	push   $0x23
  800217:	68 d5 0f 80 00       	push   $0x800fd5
  80021c:	e8 f0 00 00 00       	call   800311 <_panic>

int
sys_page_unmap(envid_t envid, void *va)
{
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800221:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800224:	5b                   	pop    %ebx
  800225:	5e                   	pop    %esi
  800226:	5f                   	pop    %edi
  800227:	5d                   	pop    %ebp
  800228:	c3                   	ret    

00800229 <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  800229:	55                   	push   %ebp
  80022a:	89 e5                	mov    %esp,%ebp
  80022c:	57                   	push   %edi
  80022d:	56                   	push   %esi
  80022e:	53                   	push   %ebx
  80022f:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800232:	bb 00 00 00 00       	mov    $0x0,%ebx
  800237:	b8 08 00 00 00       	mov    $0x8,%eax
  80023c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80023f:	8b 55 08             	mov    0x8(%ebp),%edx
  800242:	89 df                	mov    %ebx,%edi
  800244:	89 de                	mov    %ebx,%esi
  800246:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  800248:	85 c0                	test   %eax,%eax
  80024a:	7e 17                	jle    800263 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024c:	83 ec 0c             	sub    $0xc,%esp
  80024f:	50                   	push   %eax
  800250:	6a 08                	push   $0x8
  800252:	68 b8 0f 80 00       	push   $0x800fb8
  800257:	6a 23                	push   $0x23
  800259:	68 d5 0f 80 00       	push   $0x800fd5
  80025e:	e8 ae 00 00 00       	call   800311 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800263:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800266:	5b                   	pop    %ebx
  800267:	5e                   	pop    %esi
  800268:	5f                   	pop    %edi
  800269:	5d                   	pop    %ebp
  80026a:	c3                   	ret    

0080026b <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  80026b:	55                   	push   %ebp
  80026c:	89 e5                	mov    %esp,%ebp
  80026e:	57                   	push   %edi
  80026f:	56                   	push   %esi
  800270:	53                   	push   %ebx
  800271:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800274:	bb 00 00 00 00       	mov    $0x0,%ebx
  800279:	b8 09 00 00 00       	mov    $0x9,%eax
  80027e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800281:	8b 55 08             	mov    0x8(%ebp),%edx
  800284:	89 df                	mov    %ebx,%edi
  800286:	89 de                	mov    %ebx,%esi
  800288:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  80028a:	85 c0                	test   %eax,%eax
  80028c:	7e 17                	jle    8002a5 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028e:	83 ec 0c             	sub    $0xc,%esp
  800291:	50                   	push   %eax
  800292:	6a 09                	push   $0x9
  800294:	68 b8 0f 80 00       	push   $0x800fb8
  800299:	6a 23                	push   $0x23
  80029b:	68 d5 0f 80 00       	push   $0x800fd5
  8002a0:	e8 6c 00 00 00       	call   800311 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a8:	5b                   	pop    %ebx
  8002a9:	5e                   	pop    %esi
  8002aa:	5f                   	pop    %edi
  8002ab:	5d                   	pop    %ebp
  8002ac:	c3                   	ret    

008002ad <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002ad:	55                   	push   %ebp
  8002ae:	89 e5                	mov    %esp,%ebp
  8002b0:	57                   	push   %edi
  8002b1:	56                   	push   %esi
  8002b2:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002b3:	be 00 00 00 00       	mov    $0x0,%esi
  8002b8:	b8 0b 00 00 00       	mov    $0xb,%eax
  8002bd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c0:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c3:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8002c6:	8b 7d 14             	mov    0x14(%ebp),%edi
  8002c9:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  8002cb:	5b                   	pop    %ebx
  8002cc:	5e                   	pop    %esi
  8002cd:	5f                   	pop    %edi
  8002ce:	5d                   	pop    %ebp
  8002cf:	c3                   	ret    

008002d0 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  8002d0:	55                   	push   %ebp
  8002d1:	89 e5                	mov    %esp,%ebp
  8002d3:	57                   	push   %edi
  8002d4:	56                   	push   %esi
  8002d5:	53                   	push   %ebx
  8002d6:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002d9:	b9 00 00 00 00       	mov    $0x0,%ecx
  8002de:	b8 0c 00 00 00       	mov    $0xc,%eax
  8002e3:	8b 55 08             	mov    0x8(%ebp),%edx
  8002e6:	89 cb                	mov    %ecx,%ebx
  8002e8:	89 cf                	mov    %ecx,%edi
  8002ea:	89 ce                	mov    %ecx,%esi
  8002ec:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");

	if(check && ret > 0)
  8002ee:	85 c0                	test   %eax,%eax
  8002f0:	7e 17                	jle    800309 <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002f2:	83 ec 0c             	sub    $0xc,%esp
  8002f5:	50                   	push   %eax
  8002f6:	6a 0c                	push   $0xc
  8002f8:	68 b8 0f 80 00       	push   $0x800fb8
  8002fd:	6a 23                	push   $0x23
  8002ff:	68 d5 0f 80 00       	push   $0x800fd5
  800304:	e8 08 00 00 00       	call   800311 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  800309:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80030c:	5b                   	pop    %ebx
  80030d:	5e                   	pop    %esi
  80030e:	5f                   	pop    %edi
  80030f:	5d                   	pop    %ebp
  800310:	c3                   	ret    

00800311 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  800311:	55                   	push   %ebp
  800312:	89 e5                	mov    %esp,%ebp
  800314:	56                   	push   %esi
  800315:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  800316:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  800319:	8b 35 04 20 80 00    	mov    0x802004,%esi
  80031f:	e8 00 fe ff ff       	call   800124 <sys_getenvid>
  800324:	83 ec 0c             	sub    $0xc,%esp
  800327:	ff 75 0c             	pushl  0xc(%ebp)
  80032a:	ff 75 08             	pushl  0x8(%ebp)
  80032d:	56                   	push   %esi
  80032e:	50                   	push   %eax
  80032f:	68 e4 0f 80 00       	push   $0x800fe4
  800334:	e8 b1 00 00 00       	call   8003ea <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  800339:	83 c4 18             	add    $0x18,%esp
  80033c:	53                   	push   %ebx
  80033d:	ff 75 10             	pushl  0x10(%ebp)
  800340:	e8 54 00 00 00       	call   800399 <vcprintf>
	cprintf("\n");
  800345:	c7 04 24 ac 0f 80 00 	movl   $0x800fac,(%esp)
  80034c:	e8 99 00 00 00       	call   8003ea <cprintf>
  800351:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  800354:	cc                   	int3   
  800355:	eb fd                	jmp    800354 <_panic+0x43>

00800357 <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  800357:	55                   	push   %ebp
  800358:	89 e5                	mov    %esp,%ebp
  80035a:	53                   	push   %ebx
  80035b:	83 ec 04             	sub    $0x4,%esp
  80035e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  800361:	8b 13                	mov    (%ebx),%edx
  800363:	8d 42 01             	lea    0x1(%edx),%eax
  800366:	89 03                	mov    %eax,(%ebx)
  800368:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80036b:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  80036f:	3d ff 00 00 00       	cmp    $0xff,%eax
  800374:	75 1a                	jne    800390 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  800376:	83 ec 08             	sub    $0x8,%esp
  800379:	68 ff 00 00 00       	push   $0xff
  80037e:	8d 43 08             	lea    0x8(%ebx),%eax
  800381:	50                   	push   %eax
  800382:	e8 1f fd ff ff       	call   8000a6 <sys_cputs>
		b->idx = 0;
  800387:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  80038d:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  800390:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  800394:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800397:	c9                   	leave  
  800398:	c3                   	ret    

00800399 <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  800399:	55                   	push   %ebp
  80039a:	89 e5                	mov    %esp,%ebp
  80039c:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8003a2:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8003a9:	00 00 00 
	b.cnt = 0;
  8003ac:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8003b3:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8003b6:	ff 75 0c             	pushl  0xc(%ebp)
  8003b9:	ff 75 08             	pushl  0x8(%ebp)
  8003bc:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8003c2:	50                   	push   %eax
  8003c3:	68 57 03 80 00       	push   $0x800357
  8003c8:	e8 54 01 00 00       	call   800521 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8003cd:	83 c4 08             	add    $0x8,%esp
  8003d0:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8003d6:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  8003dc:	50                   	push   %eax
  8003dd:	e8 c4 fc ff ff       	call   8000a6 <sys_cputs>

	return b.cnt;
}
  8003e2:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  8003e8:	c9                   	leave  
  8003e9:	c3                   	ret    

008003ea <cprintf>:

int
cprintf(const char *fmt, ...)
{
  8003ea:	55                   	push   %ebp
  8003eb:	89 e5                	mov    %esp,%ebp
  8003ed:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  8003f0:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  8003f3:	50                   	push   %eax
  8003f4:	ff 75 08             	pushl  0x8(%ebp)
  8003f7:	e8 9d ff ff ff       	call   800399 <vcprintf>
	va_end(ap);

	return cnt;
}
  8003fc:	c9                   	leave  
  8003fd:	c3                   	ret    

008003fe <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  8003fe:	55                   	push   %ebp
  8003ff:	89 e5                	mov    %esp,%ebp
  800401:	57                   	push   %edi
  800402:	56                   	push   %esi
  800403:	53                   	push   %ebx
  800404:	83 ec 1c             	sub    $0x1c,%esp
  800407:	89 c7                	mov    %eax,%edi
  800409:	89 d6                	mov    %edx,%esi
  80040b:	8b 45 08             	mov    0x8(%ebp),%eax
  80040e:	8b 55 0c             	mov    0xc(%ebp),%edx
  800411:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800414:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  800417:	8b 4d 10             	mov    0x10(%ebp),%ecx
  80041a:	bb 00 00 00 00       	mov    $0x0,%ebx
  80041f:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  800422:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  800425:	39 d3                	cmp    %edx,%ebx
  800427:	72 05                	jb     80042e <printnum+0x30>
  800429:	39 45 10             	cmp    %eax,0x10(%ebp)
  80042c:	77 45                	ja     800473 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  80042e:	83 ec 0c             	sub    $0xc,%esp
  800431:	ff 75 18             	pushl  0x18(%ebp)
  800434:	8b 45 14             	mov    0x14(%ebp),%eax
  800437:	8d 58 ff             	lea    -0x1(%eax),%ebx
  80043a:	53                   	push   %ebx
  80043b:	ff 75 10             	pushl  0x10(%ebp)
  80043e:	83 ec 08             	sub    $0x8,%esp
  800441:	ff 75 e4             	pushl  -0x1c(%ebp)
  800444:	ff 75 e0             	pushl  -0x20(%ebp)
  800447:	ff 75 dc             	pushl  -0x24(%ebp)
  80044a:	ff 75 d8             	pushl  -0x28(%ebp)
  80044d:	e8 ae 08 00 00       	call   800d00 <__udivdi3>
  800452:	83 c4 18             	add    $0x18,%esp
  800455:	52                   	push   %edx
  800456:	50                   	push   %eax
  800457:	89 f2                	mov    %esi,%edx
  800459:	89 f8                	mov    %edi,%eax
  80045b:	e8 9e ff ff ff       	call   8003fe <printnum>
  800460:	83 c4 20             	add    $0x20,%esp
  800463:	eb 18                	jmp    80047d <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  800465:	83 ec 08             	sub    $0x8,%esp
  800468:	56                   	push   %esi
  800469:	ff 75 18             	pushl  0x18(%ebp)
  80046c:	ff d7                	call   *%edi
  80046e:	83 c4 10             	add    $0x10,%esp
  800471:	eb 03                	jmp    800476 <printnum+0x78>
  800473:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  800476:	83 eb 01             	sub    $0x1,%ebx
  800479:	85 db                	test   %ebx,%ebx
  80047b:	7f e8                	jg     800465 <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  80047d:	83 ec 08             	sub    $0x8,%esp
  800480:	56                   	push   %esi
  800481:	83 ec 04             	sub    $0x4,%esp
  800484:	ff 75 e4             	pushl  -0x1c(%ebp)
  800487:	ff 75 e0             	pushl  -0x20(%ebp)
  80048a:	ff 75 dc             	pushl  -0x24(%ebp)
  80048d:	ff 75 d8             	pushl  -0x28(%ebp)
  800490:	e8 9b 09 00 00       	call   800e30 <__umoddi3>
  800495:	83 c4 14             	add    $0x14,%esp
  800498:	0f be 80 08 10 80 00 	movsbl 0x801008(%eax),%eax
  80049f:	50                   	push   %eax
  8004a0:	ff d7                	call   *%edi
}
  8004a2:	83 c4 10             	add    $0x10,%esp
  8004a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8004a8:	5b                   	pop    %ebx
  8004a9:	5e                   	pop    %esi
  8004aa:	5f                   	pop    %edi
  8004ab:	5d                   	pop    %ebp
  8004ac:	c3                   	ret    

008004ad <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8004ad:	55                   	push   %ebp
  8004ae:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8004b0:	83 fa 01             	cmp    $0x1,%edx
  8004b3:	7e 0e                	jle    8004c3 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8004b5:	8b 10                	mov    (%eax),%edx
  8004b7:	8d 4a 08             	lea    0x8(%edx),%ecx
  8004ba:	89 08                	mov    %ecx,(%eax)
  8004bc:	8b 02                	mov    (%edx),%eax
  8004be:	8b 52 04             	mov    0x4(%edx),%edx
  8004c1:	eb 22                	jmp    8004e5 <getuint+0x38>
	else if (lflag)
  8004c3:	85 d2                	test   %edx,%edx
  8004c5:	74 10                	je     8004d7 <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8004c7:	8b 10                	mov    (%eax),%edx
  8004c9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004cc:	89 08                	mov    %ecx,(%eax)
  8004ce:	8b 02                	mov    (%edx),%eax
  8004d0:	ba 00 00 00 00       	mov    $0x0,%edx
  8004d5:	eb 0e                	jmp    8004e5 <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8004d7:	8b 10                	mov    (%eax),%edx
  8004d9:	8d 4a 04             	lea    0x4(%edx),%ecx
  8004dc:	89 08                	mov    %ecx,(%eax)
  8004de:	8b 02                	mov    (%edx),%eax
  8004e0:	ba 00 00 00 00       	mov    $0x0,%edx
}
  8004e5:	5d                   	pop    %ebp
  8004e6:	c3                   	ret    

008004e7 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  8004e7:	55                   	push   %ebp
  8004e8:	89 e5                	mov    %esp,%ebp
  8004ea:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  8004ed:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  8004f1:	8b 10                	mov    (%eax),%edx
  8004f3:	3b 50 04             	cmp    0x4(%eax),%edx
  8004f6:	73 0a                	jae    800502 <sprintputch+0x1b>
		*b->buf++ = ch;
  8004f8:	8d 4a 01             	lea    0x1(%edx),%ecx
  8004fb:	89 08                	mov    %ecx,(%eax)
  8004fd:	8b 45 08             	mov    0x8(%ebp),%eax
  800500:	88 02                	mov    %al,(%edx)
}
  800502:	5d                   	pop    %ebp
  800503:	c3                   	ret    

00800504 <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  800504:	55                   	push   %ebp
  800505:	89 e5                	mov    %esp,%ebp
  800507:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  80050a:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  80050d:	50                   	push   %eax
  80050e:	ff 75 10             	pushl  0x10(%ebp)
  800511:	ff 75 0c             	pushl  0xc(%ebp)
  800514:	ff 75 08             	pushl  0x8(%ebp)
  800517:	e8 05 00 00 00       	call   800521 <vprintfmt>
	va_end(ap);
}
  80051c:	83 c4 10             	add    $0x10,%esp
  80051f:	c9                   	leave  
  800520:	c3                   	ret    

00800521 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  800521:	55                   	push   %ebp
  800522:	89 e5                	mov    %esp,%ebp
  800524:	57                   	push   %edi
  800525:	56                   	push   %esi
  800526:	53                   	push   %ebx
  800527:	83 ec 2c             	sub    $0x2c,%esp
  80052a:	8b 75 08             	mov    0x8(%ebp),%esi
  80052d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800530:	8b 7d 10             	mov    0x10(%ebp),%edi
  800533:	eb 12                	jmp    800547 <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  800535:	85 c0                	test   %eax,%eax
  800537:	0f 84 d3 03 00 00    	je     800910 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  80053d:	83 ec 08             	sub    $0x8,%esp
  800540:	53                   	push   %ebx
  800541:	50                   	push   %eax
  800542:	ff d6                	call   *%esi
  800544:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  800547:	83 c7 01             	add    $0x1,%edi
  80054a:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80054e:	83 f8 25             	cmp    $0x25,%eax
  800551:	75 e2                	jne    800535 <vprintfmt+0x14>
  800553:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  800557:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  80055e:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800565:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  80056c:	ba 00 00 00 00       	mov    $0x0,%edx
  800571:	eb 07                	jmp    80057a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800573:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  800576:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80057a:	8d 47 01             	lea    0x1(%edi),%eax
  80057d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  800580:	0f b6 07             	movzbl (%edi),%eax
  800583:	0f b6 c8             	movzbl %al,%ecx
  800586:	83 e8 23             	sub    $0x23,%eax
  800589:	3c 55                	cmp    $0x55,%al
  80058b:	0f 87 64 03 00 00    	ja     8008f5 <vprintfmt+0x3d4>
  800591:	0f b6 c0             	movzbl %al,%eax
  800594:	ff 24 85 c0 10 80 00 	jmp    *0x8010c0(,%eax,4)
  80059b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  80059e:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8005a2:	eb d6                	jmp    80057a <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005a4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005a7:	b8 00 00 00 00       	mov    $0x0,%eax
  8005ac:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8005af:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8005b2:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8005b6:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8005b9:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8005bc:	83 fa 09             	cmp    $0x9,%edx
  8005bf:	77 39                	ja     8005fa <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8005c1:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8005c4:	eb e9                	jmp    8005af <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8005c6:	8b 45 14             	mov    0x14(%ebp),%eax
  8005c9:	8d 48 04             	lea    0x4(%eax),%ecx
  8005cc:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8005cf:	8b 00                	mov    (%eax),%eax
  8005d1:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8005d7:	eb 27                	jmp    800600 <vprintfmt+0xdf>
  8005d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
  8005dc:	85 c0                	test   %eax,%eax
  8005de:	b9 00 00 00 00       	mov    $0x0,%ecx
  8005e3:	0f 49 c8             	cmovns %eax,%ecx
  8005e6:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8005e9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8005ec:	eb 8c                	jmp    80057a <vprintfmt+0x59>
  8005ee:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  8005f1:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  8005f8:	eb 80                	jmp    80057a <vprintfmt+0x59>
  8005fa:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005fd:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  800600:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  800604:	0f 89 70 ff ff ff    	jns    80057a <vprintfmt+0x59>
				width = precision, precision = -1;
  80060a:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80060d:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800610:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  800617:	e9 5e ff ff ff       	jmp    80057a <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  80061c:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80061f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  800622:	e9 53 ff ff ff       	jmp    80057a <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  800627:	8b 45 14             	mov    0x14(%ebp),%eax
  80062a:	8d 50 04             	lea    0x4(%eax),%edx
  80062d:	89 55 14             	mov    %edx,0x14(%ebp)
  800630:	83 ec 08             	sub    $0x8,%esp
  800633:	53                   	push   %ebx
  800634:	ff 30                	pushl  (%eax)
  800636:	ff d6                	call   *%esi
			break;
  800638:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80063b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  80063e:	e9 04 ff ff ff       	jmp    800547 <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  800643:	8b 45 14             	mov    0x14(%ebp),%eax
  800646:	8d 50 04             	lea    0x4(%eax),%edx
  800649:	89 55 14             	mov    %edx,0x14(%ebp)
  80064c:	8b 00                	mov    (%eax),%eax
  80064e:	99                   	cltd   
  80064f:	31 d0                	xor    %edx,%eax
  800651:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  800653:	83 f8 08             	cmp    $0x8,%eax
  800656:	7f 0b                	jg     800663 <vprintfmt+0x142>
  800658:	8b 14 85 20 12 80 00 	mov    0x801220(,%eax,4),%edx
  80065f:	85 d2                	test   %edx,%edx
  800661:	75 18                	jne    80067b <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  800663:	50                   	push   %eax
  800664:	68 20 10 80 00       	push   $0x801020
  800669:	53                   	push   %ebx
  80066a:	56                   	push   %esi
  80066b:	e8 94 fe ff ff       	call   800504 <printfmt>
  800670:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  800673:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  800676:	e9 cc fe ff ff       	jmp    800547 <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  80067b:	52                   	push   %edx
  80067c:	68 29 10 80 00       	push   $0x801029
  800681:	53                   	push   %ebx
  800682:	56                   	push   %esi
  800683:	e8 7c fe ff ff       	call   800504 <printfmt>
  800688:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80068b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  80068e:	e9 b4 fe ff ff       	jmp    800547 <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  800693:	8b 45 14             	mov    0x14(%ebp),%eax
  800696:	8d 50 04             	lea    0x4(%eax),%edx
  800699:	89 55 14             	mov    %edx,0x14(%ebp)
  80069c:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  80069e:	85 ff                	test   %edi,%edi
  8006a0:	b8 19 10 80 00       	mov    $0x801019,%eax
  8006a5:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8006a8:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8006ac:	0f 8e 94 00 00 00    	jle    800746 <vprintfmt+0x225>
  8006b2:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8006b6:	0f 84 98 00 00 00    	je     800754 <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8006bc:	83 ec 08             	sub    $0x8,%esp
  8006bf:	ff 75 c8             	pushl  -0x38(%ebp)
  8006c2:	57                   	push   %edi
  8006c3:	e8 d0 02 00 00       	call   800998 <strnlen>
  8006c8:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8006cb:	29 c1                	sub    %eax,%ecx
  8006cd:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8006d0:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8006d3:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8006d7:	89 45 e0             	mov    %eax,-0x20(%ebp)
  8006da:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  8006dd:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006df:	eb 0f                	jmp    8006f0 <vprintfmt+0x1cf>
					putch(padc, putdat);
  8006e1:	83 ec 08             	sub    $0x8,%esp
  8006e4:	53                   	push   %ebx
  8006e5:	ff 75 e0             	pushl  -0x20(%ebp)
  8006e8:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  8006ea:	83 ef 01             	sub    $0x1,%edi
  8006ed:	83 c4 10             	add    $0x10,%esp
  8006f0:	85 ff                	test   %edi,%edi
  8006f2:	7f ed                	jg     8006e1 <vprintfmt+0x1c0>
  8006f4:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  8006f7:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  8006fa:	85 c9                	test   %ecx,%ecx
  8006fc:	b8 00 00 00 00       	mov    $0x0,%eax
  800701:	0f 49 c1             	cmovns %ecx,%eax
  800704:	29 c1                	sub    %eax,%ecx
  800706:	89 75 08             	mov    %esi,0x8(%ebp)
  800709:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80070c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80070f:	89 cb                	mov    %ecx,%ebx
  800711:	eb 4d                	jmp    800760 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  800713:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  800717:	74 1b                	je     800734 <vprintfmt+0x213>
  800719:	0f be c0             	movsbl %al,%eax
  80071c:	83 e8 20             	sub    $0x20,%eax
  80071f:	83 f8 5e             	cmp    $0x5e,%eax
  800722:	76 10                	jbe    800734 <vprintfmt+0x213>
					putch('?', putdat);
  800724:	83 ec 08             	sub    $0x8,%esp
  800727:	ff 75 0c             	pushl  0xc(%ebp)
  80072a:	6a 3f                	push   $0x3f
  80072c:	ff 55 08             	call   *0x8(%ebp)
  80072f:	83 c4 10             	add    $0x10,%esp
  800732:	eb 0d                	jmp    800741 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  800734:	83 ec 08             	sub    $0x8,%esp
  800737:	ff 75 0c             	pushl  0xc(%ebp)
  80073a:	52                   	push   %edx
  80073b:	ff 55 08             	call   *0x8(%ebp)
  80073e:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  800741:	83 eb 01             	sub    $0x1,%ebx
  800744:	eb 1a                	jmp    800760 <vprintfmt+0x23f>
  800746:	89 75 08             	mov    %esi,0x8(%ebp)
  800749:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80074c:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80074f:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800752:	eb 0c                	jmp    800760 <vprintfmt+0x23f>
  800754:	89 75 08             	mov    %esi,0x8(%ebp)
  800757:	8b 75 c8             	mov    -0x38(%ebp),%esi
  80075a:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  80075d:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  800760:	83 c7 01             	add    $0x1,%edi
  800763:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  800767:	0f be d0             	movsbl %al,%edx
  80076a:	85 d2                	test   %edx,%edx
  80076c:	74 23                	je     800791 <vprintfmt+0x270>
  80076e:	85 f6                	test   %esi,%esi
  800770:	78 a1                	js     800713 <vprintfmt+0x1f2>
  800772:	83 ee 01             	sub    $0x1,%esi
  800775:	79 9c                	jns    800713 <vprintfmt+0x1f2>
  800777:	89 df                	mov    %ebx,%edi
  800779:	8b 75 08             	mov    0x8(%ebp),%esi
  80077c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  80077f:	eb 18                	jmp    800799 <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  800781:	83 ec 08             	sub    $0x8,%esp
  800784:	53                   	push   %ebx
  800785:	6a 20                	push   $0x20
  800787:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  800789:	83 ef 01             	sub    $0x1,%edi
  80078c:	83 c4 10             	add    $0x10,%esp
  80078f:	eb 08                	jmp    800799 <vprintfmt+0x278>
  800791:	89 df                	mov    %ebx,%edi
  800793:	8b 75 08             	mov    0x8(%ebp),%esi
  800796:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  800799:	85 ff                	test   %edi,%edi
  80079b:	7f e4                	jg     800781 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80079d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8007a0:	e9 a2 fd ff ff       	jmp    800547 <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8007a5:	83 fa 01             	cmp    $0x1,%edx
  8007a8:	7e 16                	jle    8007c0 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8007aa:	8b 45 14             	mov    0x14(%ebp),%eax
  8007ad:	8d 50 08             	lea    0x8(%eax),%edx
  8007b0:	89 55 14             	mov    %edx,0x14(%ebp)
  8007b3:	8b 50 04             	mov    0x4(%eax),%edx
  8007b6:	8b 00                	mov    (%eax),%eax
  8007b8:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007bb:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8007be:	eb 32                	jmp    8007f2 <vprintfmt+0x2d1>
	else if (lflag)
  8007c0:	85 d2                	test   %edx,%edx
  8007c2:	74 18                	je     8007dc <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8007c4:	8b 45 14             	mov    0x14(%ebp),%eax
  8007c7:	8d 50 04             	lea    0x4(%eax),%edx
  8007ca:	89 55 14             	mov    %edx,0x14(%ebp)
  8007cd:	8b 00                	mov    (%eax),%eax
  8007cf:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007d2:	89 c1                	mov    %eax,%ecx
  8007d4:	c1 f9 1f             	sar    $0x1f,%ecx
  8007d7:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  8007da:	eb 16                	jmp    8007f2 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  8007dc:	8b 45 14             	mov    0x14(%ebp),%eax
  8007df:	8d 50 04             	lea    0x4(%eax),%edx
  8007e2:	89 55 14             	mov    %edx,0x14(%ebp)
  8007e5:	8b 00                	mov    (%eax),%eax
  8007e7:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8007ea:	89 c1                	mov    %eax,%ecx
  8007ec:	c1 f9 1f             	sar    $0x1f,%ecx
  8007ef:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  8007f2:	8b 45 c8             	mov    -0x38(%ebp),%eax
  8007f5:	8b 55 cc             	mov    -0x34(%ebp),%edx
  8007f8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8007fb:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  8007fe:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  800803:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  800807:	0f 89 b0 00 00 00    	jns    8008bd <vprintfmt+0x39c>
				putch('-', putdat);
  80080d:	83 ec 08             	sub    $0x8,%esp
  800810:	53                   	push   %ebx
  800811:	6a 2d                	push   $0x2d
  800813:	ff d6                	call   *%esi
				num = -(long long) num;
  800815:	8b 45 c8             	mov    -0x38(%ebp),%eax
  800818:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80081b:	f7 d8                	neg    %eax
  80081d:	83 d2 00             	adc    $0x0,%edx
  800820:	f7 da                	neg    %edx
  800822:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800825:	89 55 dc             	mov    %edx,-0x24(%ebp)
  800828:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  80082b:	b8 0a 00 00 00       	mov    $0xa,%eax
  800830:	e9 88 00 00 00       	jmp    8008bd <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  800835:	8d 45 14             	lea    0x14(%ebp),%eax
  800838:	e8 70 fc ff ff       	call   8004ad <getuint>
  80083d:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800840:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  800843:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  800848:	eb 73                	jmp    8008bd <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  80084a:	8d 45 14             	lea    0x14(%ebp),%eax
  80084d:	e8 5b fc ff ff       	call   8004ad <getuint>
  800852:	89 45 d8             	mov    %eax,-0x28(%ebp)
  800855:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  800858:	83 ec 08             	sub    $0x8,%esp
  80085b:	53                   	push   %ebx
  80085c:	6a 58                	push   $0x58
  80085e:	ff d6                	call   *%esi
			putch('X', putdat);
  800860:	83 c4 08             	add    $0x8,%esp
  800863:	53                   	push   %ebx
  800864:	6a 58                	push   $0x58
  800866:	ff d6                	call   *%esi
			putch('X', putdat);
  800868:	83 c4 08             	add    $0x8,%esp
  80086b:	53                   	push   %ebx
  80086c:	6a 58                	push   $0x58
  80086e:	ff d6                	call   *%esi
			goto number;
  800870:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  800873:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  800878:	eb 43                	jmp    8008bd <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  80087a:	83 ec 08             	sub    $0x8,%esp
  80087d:	53                   	push   %ebx
  80087e:	6a 30                	push   $0x30
  800880:	ff d6                	call   *%esi
			putch('x', putdat);
  800882:	83 c4 08             	add    $0x8,%esp
  800885:	53                   	push   %ebx
  800886:	6a 78                	push   $0x78
  800888:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  80088a:	8b 45 14             	mov    0x14(%ebp),%eax
  80088d:	8d 50 04             	lea    0x4(%eax),%edx
  800890:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  800893:	8b 00                	mov    (%eax),%eax
  800895:	ba 00 00 00 00       	mov    $0x0,%edx
  80089a:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80089d:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8008a0:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8008a3:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8008a8:	eb 13                	jmp    8008bd <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8008aa:	8d 45 14             	lea    0x14(%ebp),%eax
  8008ad:	e8 fb fb ff ff       	call   8004ad <getuint>
  8008b2:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8008b5:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8008b8:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8008bd:	83 ec 0c             	sub    $0xc,%esp
  8008c0:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8008c4:	52                   	push   %edx
  8008c5:	ff 75 e0             	pushl  -0x20(%ebp)
  8008c8:	50                   	push   %eax
  8008c9:	ff 75 dc             	pushl  -0x24(%ebp)
  8008cc:	ff 75 d8             	pushl  -0x28(%ebp)
  8008cf:	89 da                	mov    %ebx,%edx
  8008d1:	89 f0                	mov    %esi,%eax
  8008d3:	e8 26 fb ff ff       	call   8003fe <printnum>
			break;
  8008d8:	83 c4 20             	add    $0x20,%esp
  8008db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8008de:	e9 64 fc ff ff       	jmp    800547 <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  8008e3:	83 ec 08             	sub    $0x8,%esp
  8008e6:	53                   	push   %ebx
  8008e7:	51                   	push   %ecx
  8008e8:	ff d6                	call   *%esi
			break;
  8008ea:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8008ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  8008f0:	e9 52 fc ff ff       	jmp    800547 <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  8008f5:	83 ec 08             	sub    $0x8,%esp
  8008f8:	53                   	push   %ebx
  8008f9:	6a 25                	push   $0x25
  8008fb:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  8008fd:	83 c4 10             	add    $0x10,%esp
  800900:	eb 03                	jmp    800905 <vprintfmt+0x3e4>
  800902:	83 ef 01             	sub    $0x1,%edi
  800905:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  800909:	75 f7                	jne    800902 <vprintfmt+0x3e1>
  80090b:	e9 37 fc ff ff       	jmp    800547 <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  800910:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800913:	5b                   	pop    %ebx
  800914:	5e                   	pop    %esi
  800915:	5f                   	pop    %edi
  800916:	5d                   	pop    %ebp
  800917:	c3                   	ret    

00800918 <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  800918:	55                   	push   %ebp
  800919:	89 e5                	mov    %esp,%ebp
  80091b:	83 ec 18             	sub    $0x18,%esp
  80091e:	8b 45 08             	mov    0x8(%ebp),%eax
  800921:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  800924:	89 45 ec             	mov    %eax,-0x14(%ebp)
  800927:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  80092b:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  80092e:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  800935:	85 c0                	test   %eax,%eax
  800937:	74 26                	je     80095f <vsnprintf+0x47>
  800939:	85 d2                	test   %edx,%edx
  80093b:	7e 22                	jle    80095f <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  80093d:	ff 75 14             	pushl  0x14(%ebp)
  800940:	ff 75 10             	pushl  0x10(%ebp)
  800943:	8d 45 ec             	lea    -0x14(%ebp),%eax
  800946:	50                   	push   %eax
  800947:	68 e7 04 80 00       	push   $0x8004e7
  80094c:	e8 d0 fb ff ff       	call   800521 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  800951:	8b 45 ec             	mov    -0x14(%ebp),%eax
  800954:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  800957:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80095a:	83 c4 10             	add    $0x10,%esp
  80095d:	eb 05                	jmp    800964 <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  80095f:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  800964:	c9                   	leave  
  800965:	c3                   	ret    

00800966 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  800966:	55                   	push   %ebp
  800967:	89 e5                	mov    %esp,%ebp
  800969:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  80096c:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  80096f:	50                   	push   %eax
  800970:	ff 75 10             	pushl  0x10(%ebp)
  800973:	ff 75 0c             	pushl  0xc(%ebp)
  800976:	ff 75 08             	pushl  0x8(%ebp)
  800979:	e8 9a ff ff ff       	call   800918 <vsnprintf>
	va_end(ap);

	return rc;
}
  80097e:	c9                   	leave  
  80097f:	c3                   	ret    

00800980 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  800980:	55                   	push   %ebp
  800981:	89 e5                	mov    %esp,%ebp
  800983:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  800986:	b8 00 00 00 00       	mov    $0x0,%eax
  80098b:	eb 03                	jmp    800990 <strlen+0x10>
		n++;
  80098d:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  800990:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  800994:	75 f7                	jne    80098d <strlen+0xd>
		n++;
	return n;
}
  800996:	5d                   	pop    %ebp
  800997:	c3                   	ret    

00800998 <strnlen>:

int
strnlen(const char *s, size_t size)
{
  800998:	55                   	push   %ebp
  800999:	89 e5                	mov    %esp,%ebp
  80099b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80099e:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009a1:	ba 00 00 00 00       	mov    $0x0,%edx
  8009a6:	eb 03                	jmp    8009ab <strnlen+0x13>
		n++;
  8009a8:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8009ab:	39 c2                	cmp    %eax,%edx
  8009ad:	74 08                	je     8009b7 <strnlen+0x1f>
  8009af:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8009b3:	75 f3                	jne    8009a8 <strnlen+0x10>
  8009b5:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8009b7:	5d                   	pop    %ebp
  8009b8:	c3                   	ret    

008009b9 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8009b9:	55                   	push   %ebp
  8009ba:	89 e5                	mov    %esp,%ebp
  8009bc:	53                   	push   %ebx
  8009bd:	8b 45 08             	mov    0x8(%ebp),%eax
  8009c0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8009c3:	89 c2                	mov    %eax,%edx
  8009c5:	83 c2 01             	add    $0x1,%edx
  8009c8:	83 c1 01             	add    $0x1,%ecx
  8009cb:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8009cf:	88 5a ff             	mov    %bl,-0x1(%edx)
  8009d2:	84 db                	test   %bl,%bl
  8009d4:	75 ef                	jne    8009c5 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8009d6:	5b                   	pop    %ebx
  8009d7:	5d                   	pop    %ebp
  8009d8:	c3                   	ret    

008009d9 <strcat>:

char *
strcat(char *dst, const char *src)
{
  8009d9:	55                   	push   %ebp
  8009da:	89 e5                	mov    %esp,%ebp
  8009dc:	53                   	push   %ebx
  8009dd:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  8009e0:	53                   	push   %ebx
  8009e1:	e8 9a ff ff ff       	call   800980 <strlen>
  8009e6:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  8009e9:	ff 75 0c             	pushl  0xc(%ebp)
  8009ec:	01 d8                	add    %ebx,%eax
  8009ee:	50                   	push   %eax
  8009ef:	e8 c5 ff ff ff       	call   8009b9 <strcpy>
	return dst;
}
  8009f4:	89 d8                	mov    %ebx,%eax
  8009f6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f9:	c9                   	leave  
  8009fa:	c3                   	ret    

008009fb <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  8009fb:	55                   	push   %ebp
  8009fc:	89 e5                	mov    %esp,%ebp
  8009fe:	56                   	push   %esi
  8009ff:	53                   	push   %ebx
  800a00:	8b 75 08             	mov    0x8(%ebp),%esi
  800a03:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a06:	89 f3                	mov    %esi,%ebx
  800a08:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a0b:	89 f2                	mov    %esi,%edx
  800a0d:	eb 0f                	jmp    800a1e <strncpy+0x23>
		*dst++ = *src;
  800a0f:	83 c2 01             	add    $0x1,%edx
  800a12:	0f b6 01             	movzbl (%ecx),%eax
  800a15:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  800a18:	80 39 01             	cmpb   $0x1,(%ecx)
  800a1b:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  800a1e:	39 da                	cmp    %ebx,%edx
  800a20:	75 ed                	jne    800a0f <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  800a22:	89 f0                	mov    %esi,%eax
  800a24:	5b                   	pop    %ebx
  800a25:	5e                   	pop    %esi
  800a26:	5d                   	pop    %ebp
  800a27:	c3                   	ret    

00800a28 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  800a28:	55                   	push   %ebp
  800a29:	89 e5                	mov    %esp,%ebp
  800a2b:	56                   	push   %esi
  800a2c:	53                   	push   %ebx
  800a2d:	8b 75 08             	mov    0x8(%ebp),%esi
  800a30:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800a33:	8b 55 10             	mov    0x10(%ebp),%edx
  800a36:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  800a38:	85 d2                	test   %edx,%edx
  800a3a:	74 21                	je     800a5d <strlcpy+0x35>
  800a3c:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  800a40:	89 f2                	mov    %esi,%edx
  800a42:	eb 09                	jmp    800a4d <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  800a44:	83 c2 01             	add    $0x1,%edx
  800a47:	83 c1 01             	add    $0x1,%ecx
  800a4a:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  800a4d:	39 c2                	cmp    %eax,%edx
  800a4f:	74 09                	je     800a5a <strlcpy+0x32>
  800a51:	0f b6 19             	movzbl (%ecx),%ebx
  800a54:	84 db                	test   %bl,%bl
  800a56:	75 ec                	jne    800a44 <strlcpy+0x1c>
  800a58:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  800a5a:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  800a5d:	29 f0                	sub    %esi,%eax
}
  800a5f:	5b                   	pop    %ebx
  800a60:	5e                   	pop    %esi
  800a61:	5d                   	pop    %ebp
  800a62:	c3                   	ret    

00800a63 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  800a63:	55                   	push   %ebp
  800a64:	89 e5                	mov    %esp,%ebp
  800a66:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800a69:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  800a6c:	eb 06                	jmp    800a74 <strcmp+0x11>
		p++, q++;
  800a6e:	83 c1 01             	add    $0x1,%ecx
  800a71:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  800a74:	0f b6 01             	movzbl (%ecx),%eax
  800a77:	84 c0                	test   %al,%al
  800a79:	74 04                	je     800a7f <strcmp+0x1c>
  800a7b:	3a 02                	cmp    (%edx),%al
  800a7d:	74 ef                	je     800a6e <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  800a7f:	0f b6 c0             	movzbl %al,%eax
  800a82:	0f b6 12             	movzbl (%edx),%edx
  800a85:	29 d0                	sub    %edx,%eax
}
  800a87:	5d                   	pop    %ebp
  800a88:	c3                   	ret    

00800a89 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  800a89:	55                   	push   %ebp
  800a8a:	89 e5                	mov    %esp,%ebp
  800a8c:	53                   	push   %ebx
  800a8d:	8b 45 08             	mov    0x8(%ebp),%eax
  800a90:	8b 55 0c             	mov    0xc(%ebp),%edx
  800a93:	89 c3                	mov    %eax,%ebx
  800a95:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  800a98:	eb 06                	jmp    800aa0 <strncmp+0x17>
		n--, p++, q++;
  800a9a:	83 c0 01             	add    $0x1,%eax
  800a9d:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  800aa0:	39 d8                	cmp    %ebx,%eax
  800aa2:	74 15                	je     800ab9 <strncmp+0x30>
  800aa4:	0f b6 08             	movzbl (%eax),%ecx
  800aa7:	84 c9                	test   %cl,%cl
  800aa9:	74 04                	je     800aaf <strncmp+0x26>
  800aab:	3a 0a                	cmp    (%edx),%cl
  800aad:	74 eb                	je     800a9a <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  800aaf:	0f b6 00             	movzbl (%eax),%eax
  800ab2:	0f b6 12             	movzbl (%edx),%edx
  800ab5:	29 d0                	sub    %edx,%eax
  800ab7:	eb 05                	jmp    800abe <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  800ab9:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  800abe:	5b                   	pop    %ebx
  800abf:	5d                   	pop    %ebp
  800ac0:	c3                   	ret    

00800ac1 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  800ac1:	55                   	push   %ebp
  800ac2:	89 e5                	mov    %esp,%ebp
  800ac4:	8b 45 08             	mov    0x8(%ebp),%eax
  800ac7:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800acb:	eb 07                	jmp    800ad4 <strchr+0x13>
		if (*s == c)
  800acd:	38 ca                	cmp    %cl,%dl
  800acf:	74 0f                	je     800ae0 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  800ad1:	83 c0 01             	add    $0x1,%eax
  800ad4:	0f b6 10             	movzbl (%eax),%edx
  800ad7:	84 d2                	test   %dl,%dl
  800ad9:	75 f2                	jne    800acd <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  800adb:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800ae0:	5d                   	pop    %ebp
  800ae1:	c3                   	ret    

00800ae2 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  800ae2:	55                   	push   %ebp
  800ae3:	89 e5                	mov    %esp,%ebp
  800ae5:	8b 45 08             	mov    0x8(%ebp),%eax
  800ae8:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  800aec:	eb 03                	jmp    800af1 <strfind+0xf>
  800aee:	83 c0 01             	add    $0x1,%eax
  800af1:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  800af4:	38 ca                	cmp    %cl,%dl
  800af6:	74 04                	je     800afc <strfind+0x1a>
  800af8:	84 d2                	test   %dl,%dl
  800afa:	75 f2                	jne    800aee <strfind+0xc>
			break;
	return (char *) s;
}
  800afc:	5d                   	pop    %ebp
  800afd:	c3                   	ret    

00800afe <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  800afe:	55                   	push   %ebp
  800aff:	89 e5                	mov    %esp,%ebp
  800b01:	57                   	push   %edi
  800b02:	56                   	push   %esi
  800b03:	53                   	push   %ebx
  800b04:	8b 7d 08             	mov    0x8(%ebp),%edi
  800b07:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  800b0a:	85 c9                	test   %ecx,%ecx
  800b0c:	74 36                	je     800b44 <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  800b0e:	f7 c7 03 00 00 00    	test   $0x3,%edi
  800b14:	75 28                	jne    800b3e <memset+0x40>
  800b16:	f6 c1 03             	test   $0x3,%cl
  800b19:	75 23                	jne    800b3e <memset+0x40>
		c &= 0xFF;
  800b1b:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  800b1f:	89 d3                	mov    %edx,%ebx
  800b21:	c1 e3 08             	shl    $0x8,%ebx
  800b24:	89 d6                	mov    %edx,%esi
  800b26:	c1 e6 18             	shl    $0x18,%esi
  800b29:	89 d0                	mov    %edx,%eax
  800b2b:	c1 e0 10             	shl    $0x10,%eax
  800b2e:	09 f0                	or     %esi,%eax
  800b30:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  800b32:	89 d8                	mov    %ebx,%eax
  800b34:	09 d0                	or     %edx,%eax
  800b36:	c1 e9 02             	shr    $0x2,%ecx
  800b39:	fc                   	cld    
  800b3a:	f3 ab                	rep stos %eax,%es:(%edi)
  800b3c:	eb 06                	jmp    800b44 <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  800b3e:	8b 45 0c             	mov    0xc(%ebp),%eax
  800b41:	fc                   	cld    
  800b42:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  800b44:	89 f8                	mov    %edi,%eax
  800b46:	5b                   	pop    %ebx
  800b47:	5e                   	pop    %esi
  800b48:	5f                   	pop    %edi
  800b49:	5d                   	pop    %ebp
  800b4a:	c3                   	ret    

00800b4b <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  800b4b:	55                   	push   %ebp
  800b4c:	89 e5                	mov    %esp,%ebp
  800b4e:	57                   	push   %edi
  800b4f:	56                   	push   %esi
  800b50:	8b 45 08             	mov    0x8(%ebp),%eax
  800b53:	8b 75 0c             	mov    0xc(%ebp),%esi
  800b56:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  800b59:	39 c6                	cmp    %eax,%esi
  800b5b:	73 35                	jae    800b92 <memmove+0x47>
  800b5d:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  800b60:	39 d0                	cmp    %edx,%eax
  800b62:	73 2e                	jae    800b92 <memmove+0x47>
		s += n;
		d += n;
  800b64:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b67:	89 d6                	mov    %edx,%esi
  800b69:	09 fe                	or     %edi,%esi
  800b6b:	f7 c6 03 00 00 00    	test   $0x3,%esi
  800b71:	75 13                	jne    800b86 <memmove+0x3b>
  800b73:	f6 c1 03             	test   $0x3,%cl
  800b76:	75 0e                	jne    800b86 <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  800b78:	83 ef 04             	sub    $0x4,%edi
  800b7b:	8d 72 fc             	lea    -0x4(%edx),%esi
  800b7e:	c1 e9 02             	shr    $0x2,%ecx
  800b81:	fd                   	std    
  800b82:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800b84:	eb 09                	jmp    800b8f <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  800b86:	83 ef 01             	sub    $0x1,%edi
  800b89:	8d 72 ff             	lea    -0x1(%edx),%esi
  800b8c:	fd                   	std    
  800b8d:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  800b8f:	fc                   	cld    
  800b90:	eb 1d                	jmp    800baf <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  800b92:	89 f2                	mov    %esi,%edx
  800b94:	09 c2                	or     %eax,%edx
  800b96:	f6 c2 03             	test   $0x3,%dl
  800b99:	75 0f                	jne    800baa <memmove+0x5f>
  800b9b:	f6 c1 03             	test   $0x3,%cl
  800b9e:	75 0a                	jne    800baa <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  800ba0:	c1 e9 02             	shr    $0x2,%ecx
  800ba3:	89 c7                	mov    %eax,%edi
  800ba5:	fc                   	cld    
  800ba6:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  800ba8:	eb 05                	jmp    800baf <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  800baa:	89 c7                	mov    %eax,%edi
  800bac:	fc                   	cld    
  800bad:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  800baf:	5e                   	pop    %esi
  800bb0:	5f                   	pop    %edi
  800bb1:	5d                   	pop    %ebp
  800bb2:	c3                   	ret    

00800bb3 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  800bb3:	55                   	push   %ebp
  800bb4:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  800bb6:	ff 75 10             	pushl  0x10(%ebp)
  800bb9:	ff 75 0c             	pushl  0xc(%ebp)
  800bbc:	ff 75 08             	pushl  0x8(%ebp)
  800bbf:	e8 87 ff ff ff       	call   800b4b <memmove>
}
  800bc4:	c9                   	leave  
  800bc5:	c3                   	ret    

00800bc6 <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  800bc6:	55                   	push   %ebp
  800bc7:	89 e5                	mov    %esp,%ebp
  800bc9:	56                   	push   %esi
  800bca:	53                   	push   %ebx
  800bcb:	8b 45 08             	mov    0x8(%ebp),%eax
  800bce:	8b 55 0c             	mov    0xc(%ebp),%edx
  800bd1:	89 c6                	mov    %eax,%esi
  800bd3:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bd6:	eb 1a                	jmp    800bf2 <memcmp+0x2c>
		if (*s1 != *s2)
  800bd8:	0f b6 08             	movzbl (%eax),%ecx
  800bdb:	0f b6 1a             	movzbl (%edx),%ebx
  800bde:	38 d9                	cmp    %bl,%cl
  800be0:	74 0a                	je     800bec <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  800be2:	0f b6 c1             	movzbl %cl,%eax
  800be5:	0f b6 db             	movzbl %bl,%ebx
  800be8:	29 d8                	sub    %ebx,%eax
  800bea:	eb 0f                	jmp    800bfb <memcmp+0x35>
		s1++, s2++;
  800bec:	83 c0 01             	add    $0x1,%eax
  800bef:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  800bf2:	39 f0                	cmp    %esi,%eax
  800bf4:	75 e2                	jne    800bd8 <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  800bf6:	b8 00 00 00 00       	mov    $0x0,%eax
}
  800bfb:	5b                   	pop    %ebx
  800bfc:	5e                   	pop    %esi
  800bfd:	5d                   	pop    %ebp
  800bfe:	c3                   	ret    

00800bff <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  800bff:	55                   	push   %ebp
  800c00:	89 e5                	mov    %esp,%ebp
  800c02:	53                   	push   %ebx
  800c03:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  800c06:	89 c1                	mov    %eax,%ecx
  800c08:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  800c0b:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c0f:	eb 0a                	jmp    800c1b <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  800c11:	0f b6 10             	movzbl (%eax),%edx
  800c14:	39 da                	cmp    %ebx,%edx
  800c16:	74 07                	je     800c1f <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  800c18:	83 c0 01             	add    $0x1,%eax
  800c1b:	39 c8                	cmp    %ecx,%eax
  800c1d:	72 f2                	jb     800c11 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  800c1f:	5b                   	pop    %ebx
  800c20:	5d                   	pop    %ebp
  800c21:	c3                   	ret    

00800c22 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  800c22:	55                   	push   %ebp
  800c23:	89 e5                	mov    %esp,%ebp
  800c25:	57                   	push   %edi
  800c26:	56                   	push   %esi
  800c27:	53                   	push   %ebx
  800c28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800c2b:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c2e:	eb 03                	jmp    800c33 <strtol+0x11>
		s++;
  800c30:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  800c33:	0f b6 01             	movzbl (%ecx),%eax
  800c36:	3c 20                	cmp    $0x20,%al
  800c38:	74 f6                	je     800c30 <strtol+0xe>
  800c3a:	3c 09                	cmp    $0x9,%al
  800c3c:	74 f2                	je     800c30 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  800c3e:	3c 2b                	cmp    $0x2b,%al
  800c40:	75 0a                	jne    800c4c <strtol+0x2a>
		s++;
  800c42:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  800c45:	bf 00 00 00 00       	mov    $0x0,%edi
  800c4a:	eb 11                	jmp    800c5d <strtol+0x3b>
  800c4c:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  800c51:	3c 2d                	cmp    $0x2d,%al
  800c53:	75 08                	jne    800c5d <strtol+0x3b>
		s++, neg = 1;
  800c55:	83 c1 01             	add    $0x1,%ecx
  800c58:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  800c5d:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  800c63:	75 15                	jne    800c7a <strtol+0x58>
  800c65:	80 39 30             	cmpb   $0x30,(%ecx)
  800c68:	75 10                	jne    800c7a <strtol+0x58>
  800c6a:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  800c6e:	75 7c                	jne    800cec <strtol+0xca>
		s += 2, base = 16;
  800c70:	83 c1 02             	add    $0x2,%ecx
  800c73:	bb 10 00 00 00       	mov    $0x10,%ebx
  800c78:	eb 16                	jmp    800c90 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  800c7a:	85 db                	test   %ebx,%ebx
  800c7c:	75 12                	jne    800c90 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  800c7e:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800c83:	80 39 30             	cmpb   $0x30,(%ecx)
  800c86:	75 08                	jne    800c90 <strtol+0x6e>
		s++, base = 8;
  800c88:	83 c1 01             	add    $0x1,%ecx
  800c8b:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  800c90:	b8 00 00 00 00       	mov    $0x0,%eax
  800c95:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  800c98:	0f b6 11             	movzbl (%ecx),%edx
  800c9b:	8d 72 d0             	lea    -0x30(%edx),%esi
  800c9e:	89 f3                	mov    %esi,%ebx
  800ca0:	80 fb 09             	cmp    $0x9,%bl
  800ca3:	77 08                	ja     800cad <strtol+0x8b>
			dig = *s - '0';
  800ca5:	0f be d2             	movsbl %dl,%edx
  800ca8:	83 ea 30             	sub    $0x30,%edx
  800cab:	eb 22                	jmp    800ccf <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  800cad:	8d 72 9f             	lea    -0x61(%edx),%esi
  800cb0:	89 f3                	mov    %esi,%ebx
  800cb2:	80 fb 19             	cmp    $0x19,%bl
  800cb5:	77 08                	ja     800cbf <strtol+0x9d>
			dig = *s - 'a' + 10;
  800cb7:	0f be d2             	movsbl %dl,%edx
  800cba:	83 ea 57             	sub    $0x57,%edx
  800cbd:	eb 10                	jmp    800ccf <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  800cbf:	8d 72 bf             	lea    -0x41(%edx),%esi
  800cc2:	89 f3                	mov    %esi,%ebx
  800cc4:	80 fb 19             	cmp    $0x19,%bl
  800cc7:	77 16                	ja     800cdf <strtol+0xbd>
			dig = *s - 'A' + 10;
  800cc9:	0f be d2             	movsbl %dl,%edx
  800ccc:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  800ccf:	3b 55 10             	cmp    0x10(%ebp),%edx
  800cd2:	7d 0b                	jge    800cdf <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  800cd4:	83 c1 01             	add    $0x1,%ecx
  800cd7:	0f af 45 10          	imul   0x10(%ebp),%eax
  800cdb:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  800cdd:	eb b9                	jmp    800c98 <strtol+0x76>

	if (endptr)
  800cdf:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  800ce3:	74 0d                	je     800cf2 <strtol+0xd0>
		*endptr = (char *) s;
  800ce5:	8b 75 0c             	mov    0xc(%ebp),%esi
  800ce8:	89 0e                	mov    %ecx,(%esi)
  800cea:	eb 06                	jmp    800cf2 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  800cec:	85 db                	test   %ebx,%ebx
  800cee:	74 98                	je     800c88 <strtol+0x66>
  800cf0:	eb 9e                	jmp    800c90 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  800cf2:	89 c2                	mov    %eax,%edx
  800cf4:	f7 da                	neg    %edx
  800cf6:	85 ff                	test   %edi,%edi
  800cf8:	0f 45 c2             	cmovne %edx,%eax
}
  800cfb:	5b                   	pop    %ebx
  800cfc:	5e                   	pop    %esi
  800cfd:	5f                   	pop    %edi
  800cfe:	5d                   	pop    %ebp
  800cff:	c3                   	ret    

00800d00 <__udivdi3>:
  800d00:	55                   	push   %ebp
  800d01:	57                   	push   %edi
  800d02:	56                   	push   %esi
  800d03:	53                   	push   %ebx
  800d04:	83 ec 1c             	sub    $0x1c,%esp
  800d07:	8b 74 24 3c          	mov    0x3c(%esp),%esi
  800d0b:	8b 5c 24 30          	mov    0x30(%esp),%ebx
  800d0f:	8b 4c 24 34          	mov    0x34(%esp),%ecx
  800d13:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800d17:	85 f6                	test   %esi,%esi
  800d19:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800d1d:	89 ca                	mov    %ecx,%edx
  800d1f:	89 f8                	mov    %edi,%eax
  800d21:	75 3d                	jne    800d60 <__udivdi3+0x60>
  800d23:	39 cf                	cmp    %ecx,%edi
  800d25:	0f 87 c5 00 00 00    	ja     800df0 <__udivdi3+0xf0>
  800d2b:	85 ff                	test   %edi,%edi
  800d2d:	89 fd                	mov    %edi,%ebp
  800d2f:	75 0b                	jne    800d3c <__udivdi3+0x3c>
  800d31:	b8 01 00 00 00       	mov    $0x1,%eax
  800d36:	31 d2                	xor    %edx,%edx
  800d38:	f7 f7                	div    %edi
  800d3a:	89 c5                	mov    %eax,%ebp
  800d3c:	89 c8                	mov    %ecx,%eax
  800d3e:	31 d2                	xor    %edx,%edx
  800d40:	f7 f5                	div    %ebp
  800d42:	89 c1                	mov    %eax,%ecx
  800d44:	89 d8                	mov    %ebx,%eax
  800d46:	89 cf                	mov    %ecx,%edi
  800d48:	f7 f5                	div    %ebp
  800d4a:	89 c3                	mov    %eax,%ebx
  800d4c:	89 d8                	mov    %ebx,%eax
  800d4e:	89 fa                	mov    %edi,%edx
  800d50:	83 c4 1c             	add    $0x1c,%esp
  800d53:	5b                   	pop    %ebx
  800d54:	5e                   	pop    %esi
  800d55:	5f                   	pop    %edi
  800d56:	5d                   	pop    %ebp
  800d57:	c3                   	ret    
  800d58:	90                   	nop
  800d59:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800d60:	39 ce                	cmp    %ecx,%esi
  800d62:	77 74                	ja     800dd8 <__udivdi3+0xd8>
  800d64:	0f bd fe             	bsr    %esi,%edi
  800d67:	83 f7 1f             	xor    $0x1f,%edi
  800d6a:	0f 84 98 00 00 00    	je     800e08 <__udivdi3+0x108>
  800d70:	bb 20 00 00 00       	mov    $0x20,%ebx
  800d75:	89 f9                	mov    %edi,%ecx
  800d77:	89 c5                	mov    %eax,%ebp
  800d79:	29 fb                	sub    %edi,%ebx
  800d7b:	d3 e6                	shl    %cl,%esi
  800d7d:	89 d9                	mov    %ebx,%ecx
  800d7f:	d3 ed                	shr    %cl,%ebp
  800d81:	89 f9                	mov    %edi,%ecx
  800d83:	d3 e0                	shl    %cl,%eax
  800d85:	09 ee                	or     %ebp,%esi
  800d87:	89 d9                	mov    %ebx,%ecx
  800d89:	89 44 24 0c          	mov    %eax,0xc(%esp)
  800d8d:	89 d5                	mov    %edx,%ebp
  800d8f:	8b 44 24 08          	mov    0x8(%esp),%eax
  800d93:	d3 ed                	shr    %cl,%ebp
  800d95:	89 f9                	mov    %edi,%ecx
  800d97:	d3 e2                	shl    %cl,%edx
  800d99:	89 d9                	mov    %ebx,%ecx
  800d9b:	d3 e8                	shr    %cl,%eax
  800d9d:	09 c2                	or     %eax,%edx
  800d9f:	89 d0                	mov    %edx,%eax
  800da1:	89 ea                	mov    %ebp,%edx
  800da3:	f7 f6                	div    %esi
  800da5:	89 d5                	mov    %edx,%ebp
  800da7:	89 c3                	mov    %eax,%ebx
  800da9:	f7 64 24 0c          	mull   0xc(%esp)
  800dad:	39 d5                	cmp    %edx,%ebp
  800daf:	72 10                	jb     800dc1 <__udivdi3+0xc1>
  800db1:	8b 74 24 08          	mov    0x8(%esp),%esi
  800db5:	89 f9                	mov    %edi,%ecx
  800db7:	d3 e6                	shl    %cl,%esi
  800db9:	39 c6                	cmp    %eax,%esi
  800dbb:	73 07                	jae    800dc4 <__udivdi3+0xc4>
  800dbd:	39 d5                	cmp    %edx,%ebp
  800dbf:	75 03                	jne    800dc4 <__udivdi3+0xc4>
  800dc1:	83 eb 01             	sub    $0x1,%ebx
  800dc4:	31 ff                	xor    %edi,%edi
  800dc6:	89 d8                	mov    %ebx,%eax
  800dc8:	89 fa                	mov    %edi,%edx
  800dca:	83 c4 1c             	add    $0x1c,%esp
  800dcd:	5b                   	pop    %ebx
  800dce:	5e                   	pop    %esi
  800dcf:	5f                   	pop    %edi
  800dd0:	5d                   	pop    %ebp
  800dd1:	c3                   	ret    
  800dd2:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800dd8:	31 ff                	xor    %edi,%edi
  800dda:	31 db                	xor    %ebx,%ebx
  800ddc:	89 d8                	mov    %ebx,%eax
  800dde:	89 fa                	mov    %edi,%edx
  800de0:	83 c4 1c             	add    $0x1c,%esp
  800de3:	5b                   	pop    %ebx
  800de4:	5e                   	pop    %esi
  800de5:	5f                   	pop    %edi
  800de6:	5d                   	pop    %ebp
  800de7:	c3                   	ret    
  800de8:	90                   	nop
  800de9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800df0:	89 d8                	mov    %ebx,%eax
  800df2:	f7 f7                	div    %edi
  800df4:	31 ff                	xor    %edi,%edi
  800df6:	89 c3                	mov    %eax,%ebx
  800df8:	89 d8                	mov    %ebx,%eax
  800dfa:	89 fa                	mov    %edi,%edx
  800dfc:	83 c4 1c             	add    $0x1c,%esp
  800dff:	5b                   	pop    %ebx
  800e00:	5e                   	pop    %esi
  800e01:	5f                   	pop    %edi
  800e02:	5d                   	pop    %ebp
  800e03:	c3                   	ret    
  800e04:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800e08:	39 ce                	cmp    %ecx,%esi
  800e0a:	72 0c                	jb     800e18 <__udivdi3+0x118>
  800e0c:	31 db                	xor    %ebx,%ebx
  800e0e:	3b 44 24 08          	cmp    0x8(%esp),%eax
  800e12:	0f 87 34 ff ff ff    	ja     800d4c <__udivdi3+0x4c>
  800e18:	bb 01 00 00 00       	mov    $0x1,%ebx
  800e1d:	e9 2a ff ff ff       	jmp    800d4c <__udivdi3+0x4c>
  800e22:	66 90                	xchg   %ax,%ax
  800e24:	66 90                	xchg   %ax,%ax
  800e26:	66 90                	xchg   %ax,%ax
  800e28:	66 90                	xchg   %ax,%ax
  800e2a:	66 90                	xchg   %ax,%ax
  800e2c:	66 90                	xchg   %ax,%ax
  800e2e:	66 90                	xchg   %ax,%ax

00800e30 <__umoddi3>:
  800e30:	55                   	push   %ebp
  800e31:	57                   	push   %edi
  800e32:	56                   	push   %esi
  800e33:	53                   	push   %ebx
  800e34:	83 ec 1c             	sub    $0x1c,%esp
  800e37:	8b 54 24 3c          	mov    0x3c(%esp),%edx
  800e3b:	8b 4c 24 30          	mov    0x30(%esp),%ecx
  800e3f:	8b 74 24 34          	mov    0x34(%esp),%esi
  800e43:	8b 7c 24 38          	mov    0x38(%esp),%edi
  800e47:	85 d2                	test   %edx,%edx
  800e49:	89 4c 24 0c          	mov    %ecx,0xc(%esp)
  800e4d:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800e51:	89 f3                	mov    %esi,%ebx
  800e53:	89 3c 24             	mov    %edi,(%esp)
  800e56:	89 74 24 04          	mov    %esi,0x4(%esp)
  800e5a:	75 1c                	jne    800e78 <__umoddi3+0x48>
  800e5c:	39 f7                	cmp    %esi,%edi
  800e5e:	76 50                	jbe    800eb0 <__umoddi3+0x80>
  800e60:	89 c8                	mov    %ecx,%eax
  800e62:	89 f2                	mov    %esi,%edx
  800e64:	f7 f7                	div    %edi
  800e66:	89 d0                	mov    %edx,%eax
  800e68:	31 d2                	xor    %edx,%edx
  800e6a:	83 c4 1c             	add    $0x1c,%esp
  800e6d:	5b                   	pop    %ebx
  800e6e:	5e                   	pop    %esi
  800e6f:	5f                   	pop    %edi
  800e70:	5d                   	pop    %ebp
  800e71:	c3                   	ret    
  800e72:	8d b6 00 00 00 00    	lea    0x0(%esi),%esi
  800e78:	39 f2                	cmp    %esi,%edx
  800e7a:	89 d0                	mov    %edx,%eax
  800e7c:	77 52                	ja     800ed0 <__umoddi3+0xa0>
  800e7e:	0f bd ea             	bsr    %edx,%ebp
  800e81:	83 f5 1f             	xor    $0x1f,%ebp
  800e84:	75 5a                	jne    800ee0 <__umoddi3+0xb0>
  800e86:	3b 54 24 04          	cmp    0x4(%esp),%edx
  800e8a:	0f 82 e0 00 00 00    	jb     800f70 <__umoddi3+0x140>
  800e90:	39 0c 24             	cmp    %ecx,(%esp)
  800e93:	0f 86 d7 00 00 00    	jbe    800f70 <__umoddi3+0x140>
  800e99:	8b 44 24 08          	mov    0x8(%esp),%eax
  800e9d:	8b 54 24 04          	mov    0x4(%esp),%edx
  800ea1:	83 c4 1c             	add    $0x1c,%esp
  800ea4:	5b                   	pop    %ebx
  800ea5:	5e                   	pop    %esi
  800ea6:	5f                   	pop    %edi
  800ea7:	5d                   	pop    %ebp
  800ea8:	c3                   	ret    
  800ea9:	8d b4 26 00 00 00 00 	lea    0x0(%esi,%eiz,1),%esi
  800eb0:	85 ff                	test   %edi,%edi
  800eb2:	89 fd                	mov    %edi,%ebp
  800eb4:	75 0b                	jne    800ec1 <__umoddi3+0x91>
  800eb6:	b8 01 00 00 00       	mov    $0x1,%eax
  800ebb:	31 d2                	xor    %edx,%edx
  800ebd:	f7 f7                	div    %edi
  800ebf:	89 c5                	mov    %eax,%ebp
  800ec1:	89 f0                	mov    %esi,%eax
  800ec3:	31 d2                	xor    %edx,%edx
  800ec5:	f7 f5                	div    %ebp
  800ec7:	89 c8                	mov    %ecx,%eax
  800ec9:	f7 f5                	div    %ebp
  800ecb:	89 d0                	mov    %edx,%eax
  800ecd:	eb 99                	jmp    800e68 <__umoddi3+0x38>
  800ecf:	90                   	nop
  800ed0:	89 c8                	mov    %ecx,%eax
  800ed2:	89 f2                	mov    %esi,%edx
  800ed4:	83 c4 1c             	add    $0x1c,%esp
  800ed7:	5b                   	pop    %ebx
  800ed8:	5e                   	pop    %esi
  800ed9:	5f                   	pop    %edi
  800eda:	5d                   	pop    %ebp
  800edb:	c3                   	ret    
  800edc:	8d 74 26 00          	lea    0x0(%esi,%eiz,1),%esi
  800ee0:	8b 34 24             	mov    (%esp),%esi
  800ee3:	bf 20 00 00 00       	mov    $0x20,%edi
  800ee8:	89 e9                	mov    %ebp,%ecx
  800eea:	29 ef                	sub    %ebp,%edi
  800eec:	d3 e0                	shl    %cl,%eax
  800eee:	89 f9                	mov    %edi,%ecx
  800ef0:	89 f2                	mov    %esi,%edx
  800ef2:	d3 ea                	shr    %cl,%edx
  800ef4:	89 e9                	mov    %ebp,%ecx
  800ef6:	09 c2                	or     %eax,%edx
  800ef8:	89 d8                	mov    %ebx,%eax
  800efa:	89 14 24             	mov    %edx,(%esp)
  800efd:	89 f2                	mov    %esi,%edx
  800eff:	d3 e2                	shl    %cl,%edx
  800f01:	89 f9                	mov    %edi,%ecx
  800f03:	89 54 24 04          	mov    %edx,0x4(%esp)
  800f07:	8b 54 24 0c          	mov    0xc(%esp),%edx
  800f0b:	d3 e8                	shr    %cl,%eax
  800f0d:	89 e9                	mov    %ebp,%ecx
  800f0f:	89 c6                	mov    %eax,%esi
  800f11:	d3 e3                	shl    %cl,%ebx
  800f13:	89 f9                	mov    %edi,%ecx
  800f15:	89 d0                	mov    %edx,%eax
  800f17:	d3 e8                	shr    %cl,%eax
  800f19:	89 e9                	mov    %ebp,%ecx
  800f1b:	09 d8                	or     %ebx,%eax
  800f1d:	89 d3                	mov    %edx,%ebx
  800f1f:	89 f2                	mov    %esi,%edx
  800f21:	f7 34 24             	divl   (%esp)
  800f24:	89 d6                	mov    %edx,%esi
  800f26:	d3 e3                	shl    %cl,%ebx
  800f28:	f7 64 24 04          	mull   0x4(%esp)
  800f2c:	39 d6                	cmp    %edx,%esi
  800f2e:	89 5c 24 08          	mov    %ebx,0x8(%esp)
  800f32:	89 d1                	mov    %edx,%ecx
  800f34:	89 c3                	mov    %eax,%ebx
  800f36:	72 08                	jb     800f40 <__umoddi3+0x110>
  800f38:	75 11                	jne    800f4b <__umoddi3+0x11b>
  800f3a:	39 44 24 08          	cmp    %eax,0x8(%esp)
  800f3e:	73 0b                	jae    800f4b <__umoddi3+0x11b>
  800f40:	2b 44 24 04          	sub    0x4(%esp),%eax
  800f44:	1b 14 24             	sbb    (%esp),%edx
  800f47:	89 d1                	mov    %edx,%ecx
  800f49:	89 c3                	mov    %eax,%ebx
  800f4b:	8b 54 24 08          	mov    0x8(%esp),%edx
  800f4f:	29 da                	sub    %ebx,%edx
  800f51:	19 ce                	sbb    %ecx,%esi
  800f53:	89 f9                	mov    %edi,%ecx
  800f55:	89 f0                	mov    %esi,%eax
  800f57:	d3 e0                	shl    %cl,%eax
  800f59:	89 e9                	mov    %ebp,%ecx
  800f5b:	d3 ea                	shr    %cl,%edx
  800f5d:	89 e9                	mov    %ebp,%ecx
  800f5f:	d3 ee                	shr    %cl,%esi
  800f61:	09 d0                	or     %edx,%eax
  800f63:	89 f2                	mov    %esi,%edx
  800f65:	83 c4 1c             	add    $0x1c,%esp
  800f68:	5b                   	pop    %ebx
  800f69:	5e                   	pop    %esi
  800f6a:	5f                   	pop    %edi
  800f6b:	5d                   	pop    %ebp
  800f6c:	c3                   	ret    
  800f6d:	8d 76 00             	lea    0x0(%esi),%esi
  800f70:	29 f9                	sub    %edi,%ecx
  800f72:	19 d6                	sbb    %edx,%esi
  800f74:	89 74 24 04          	mov    %esi,0x4(%esp)
  800f78:	89 4c 24 08          	mov    %ecx,0x8(%esp)
  800f7c:	e9 18 ff ff ff       	jmp    800e99 <__umoddi3+0x69>
