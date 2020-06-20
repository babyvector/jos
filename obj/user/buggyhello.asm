
obj/user/buggyhello.debug:     file format elf32-i386


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
  80002c:	e8 16 00 00 00       	call   800047 <libmain>
1:	jmp 1b
  800031:	eb fe                	jmp    800031 <args_exist+0x5>

00800033 <umain>:

#include <inc/lib.h>

void
umain(int argc, char **argv)
{
  800033:	55                   	push   %ebp
  800034:	89 e5                	mov    %esp,%ebp
  800036:	83 ec 10             	sub    $0x10,%esp
	sys_cputs((char*)1, 1);
  800039:	6a 01                	push   $0x1
  80003b:	6a 01                	push   $0x1
  80003d:	e8 65 00 00 00       	call   8000a7 <sys_cputs>
}
  800042:	83 c4 10             	add    $0x10,%esp
  800045:	c9                   	leave  
  800046:	c3                   	ret    

00800047 <libmain>:
const volatile struct Env *thisenv;
const char *binaryname = "<unknown>";

void
libmain(int argc, char **argv)
{
  800047:	55                   	push   %ebp
  800048:	89 e5                	mov    %esp,%ebp
  80004a:	56                   	push   %esi
  80004b:	53                   	push   %ebx
  80004c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  80004f:	8b 75 0c             	mov    0xc(%ebp),%esi
	// set thisenv to point at our Env structure in envs[].
	// LAB 3: Your code here.
	
	thisenv = &envs[ENVX(sys_getenvid())];
  800052:	e8 ce 00 00 00       	call   800125 <sys_getenvid>
  800057:	25 ff 03 00 00       	and    $0x3ff,%eax
  80005c:	6b c0 7c             	imul   $0x7c,%eax,%eax
  80005f:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  800064:	a3 04 40 80 00       	mov    %eax,0x804004
	// save the name of the program so that panic() can use it
	if (argc > 0)
  800069:	85 db                	test   %ebx,%ebx
  80006b:	7e 07                	jle    800074 <libmain+0x2d>
		binaryname = argv[0];
  80006d:	8b 06                	mov    (%esi),%eax
  80006f:	a3 00 30 80 00       	mov    %eax,0x803000

	// call user main routine
	umain(argc, argv);
  800074:	83 ec 08             	sub    $0x8,%esp
  800077:	56                   	push   %esi
  800078:	53                   	push   %ebx
  800079:	e8 b5 ff ff ff       	call   800033 <umain>

	// exit gracefully
	exit();
  80007e:	e8 0a 00 00 00       	call   80008d <exit>
}
  800083:	83 c4 10             	add    $0x10,%esp
  800086:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800089:	5b                   	pop    %ebx
  80008a:	5e                   	pop    %esi
  80008b:	5d                   	pop    %ebp
  80008c:	c3                   	ret    

0080008d <exit>:

#include <inc/lib.h>

void
exit(void)
{
  80008d:	55                   	push   %ebp
  80008e:	89 e5                	mov    %esp,%ebp
  800090:	83 ec 08             	sub    $0x8,%esp
	close_all();
  800093:	e8 87 04 00 00       	call   80051f <close_all>
	sys_env_destroy(0);
  800098:	83 ec 0c             	sub    $0xc,%esp
  80009b:	6a 00                	push   $0x0
  80009d:	e8 42 00 00 00       	call   8000e4 <sys_env_destroy>
}
  8000a2:	83 c4 10             	add    $0x10,%esp
  8000a5:	c9                   	leave  
  8000a6:	c3                   	ret    

008000a7 <sys_cputs>:
	return ret;
}

void
sys_cputs(const char *s, size_t len)
{
  8000a7:	55                   	push   %ebp
  8000a8:	89 e5                	mov    %esp,%ebp
  8000aa:	57                   	push   %edi
  8000ab:	56                   	push   %esi
  8000ac:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000ad:	b8 00 00 00 00       	mov    $0x0,%eax
  8000b2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8000b5:	8b 55 08             	mov    0x8(%ebp),%edx
  8000b8:	89 c3                	mov    %eax,%ebx
  8000ba:	89 c7                	mov    %eax,%edi
  8000bc:	89 c6                	mov    %eax,%esi
  8000be:	cd 30                	int    $0x30
sys_cputs(const char *s, size_t len)
{
//	cprintf("IN LAB SYSCALL");
	
	syscall(SYS_cputs, 0, (uint32_t)s, len, 0, 0, 0);
}
  8000c0:	5b                   	pop    %ebx
  8000c1:	5e                   	pop    %esi
  8000c2:	5f                   	pop    %edi
  8000c3:	5d                   	pop    %ebp
  8000c4:	c3                   	ret    

008000c5 <sys_cgetc>:

int
sys_cgetc(void)
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
  8000cb:	ba 00 00 00 00       	mov    $0x0,%edx
  8000d0:	b8 01 00 00 00       	mov    $0x1,%eax
  8000d5:	89 d1                	mov    %edx,%ecx
  8000d7:	89 d3                	mov    %edx,%ebx
  8000d9:	89 d7                	mov    %edx,%edi
  8000db:	89 d6                	mov    %edx,%esi
  8000dd:	cd 30                	int    $0x30

int
sys_cgetc(void)
{
	return syscall(SYS_cgetc, 0, 0, 0, 0, 0, 0);
}
  8000df:	5b                   	pop    %ebx
  8000e0:	5e                   	pop    %esi
  8000e1:	5f                   	pop    %edi
  8000e2:	5d                   	pop    %ebp
  8000e3:	c3                   	ret    

008000e4 <sys_env_destroy>:

int
sys_env_destroy(envid_t envid)
{
  8000e4:	55                   	push   %ebp
  8000e5:	89 e5                	mov    %esp,%ebp
  8000e7:	57                   	push   %edi
  8000e8:	56                   	push   %esi
  8000e9:	53                   	push   %ebx
  8000ea:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8000ed:	b9 00 00 00 00       	mov    $0x0,%ecx
  8000f2:	b8 03 00 00 00       	mov    $0x3,%eax
  8000f7:	8b 55 08             	mov    0x8(%ebp),%edx
  8000fa:	89 cb                	mov    %ecx,%ebx
  8000fc:	89 cf                	mov    %ecx,%edi
  8000fe:	89 ce                	mov    %ecx,%esi
  800100:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800102:	85 c0                	test   %eax,%eax
  800104:	7e 17                	jle    80011d <sys_env_destroy+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800106:	83 ec 0c             	sub    $0xc,%esp
  800109:	50                   	push   %eax
  80010a:	6a 03                	push   $0x3
  80010c:	68 ea 1d 80 00       	push   $0x801dea
  800111:	6a 23                	push   $0x23
  800113:	68 07 1e 80 00       	push   $0x801e07
  800118:	e8 1a 0f 00 00       	call   801037 <_panic>

int
sys_env_destroy(envid_t envid)
{
	return syscall(SYS_env_destroy, 1, envid, 0, 0, 0, 0);
}
  80011d:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800120:	5b                   	pop    %ebx
  800121:	5e                   	pop    %esi
  800122:	5f                   	pop    %edi
  800123:	5d                   	pop    %ebp
  800124:	c3                   	ret    

00800125 <sys_getenvid>:

envid_t
sys_getenvid(void)
{
  800125:	55                   	push   %ebp
  800126:	89 e5                	mov    %esp,%ebp
  800128:	57                   	push   %edi
  800129:	56                   	push   %esi
  80012a:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80012b:	ba 00 00 00 00       	mov    $0x0,%edx
  800130:	b8 02 00 00 00       	mov    $0x2,%eax
  800135:	89 d1                	mov    %edx,%ecx
  800137:	89 d3                	mov    %edx,%ebx
  800139:	89 d7                	mov    %edx,%edi
  80013b:	89 d6                	mov    %edx,%esi
  80013d:	cd 30                	int    $0x30

envid_t
sys_getenvid(void)
{
	 return syscall(SYS_getenvid, 0, 0, 0, 0, 0, 0);
}
  80013f:	5b                   	pop    %ebx
  800140:	5e                   	pop    %esi
  800141:	5f                   	pop    %edi
  800142:	5d                   	pop    %ebp
  800143:	c3                   	ret    

00800144 <sys_yield>:

void
sys_yield(void)
{
  800144:	55                   	push   %ebp
  800145:	89 e5                	mov    %esp,%ebp
  800147:	57                   	push   %edi
  800148:	56                   	push   %esi
  800149:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80014a:	ba 00 00 00 00       	mov    $0x0,%edx
  80014f:	b8 0b 00 00 00       	mov    $0xb,%eax
  800154:	89 d1                	mov    %edx,%ecx
  800156:	89 d3                	mov    %edx,%ebx
  800158:	89 d7                	mov    %edx,%edi
  80015a:	89 d6                	mov    %edx,%esi
  80015c:	cd 30                	int    $0x30

void
sys_yield(void)
{
	syscall(SYS_yield, 0, 0, 0, 0, 0, 0);
}
  80015e:	5b                   	pop    %ebx
  80015f:	5e                   	pop    %esi
  800160:	5f                   	pop    %edi
  800161:	5d                   	pop    %ebp
  800162:	c3                   	ret    

00800163 <sys_page_alloc>:

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
  800163:	55                   	push   %ebp
  800164:	89 e5                	mov    %esp,%ebp
  800166:	57                   	push   %edi
  800167:	56                   	push   %esi
  800168:	53                   	push   %ebx
  800169:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80016c:	be 00 00 00 00       	mov    $0x0,%esi
  800171:	b8 04 00 00 00       	mov    $0x4,%eax
  800176:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800179:	8b 55 08             	mov    0x8(%ebp),%edx
  80017c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  80017f:	89 f7                	mov    %esi,%edi
  800181:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800183:	85 c0                	test   %eax,%eax
  800185:	7e 17                	jle    80019e <sys_page_alloc+0x3b>
		panic("syscall %d returned %d (> 0)", num, ret);
  800187:	83 ec 0c             	sub    $0xc,%esp
  80018a:	50                   	push   %eax
  80018b:	6a 04                	push   $0x4
  80018d:	68 ea 1d 80 00       	push   $0x801dea
  800192:	6a 23                	push   $0x23
  800194:	68 07 1e 80 00       	push   $0x801e07
  800199:	e8 99 0e 00 00       	call   801037 <_panic>

int
sys_page_alloc(envid_t envid, void *va, int perm)
{
	return syscall(SYS_page_alloc, 1, envid, (uint32_t) va, perm, 0, 0);
}
  80019e:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001a1:	5b                   	pop    %ebx
  8001a2:	5e                   	pop    %esi
  8001a3:	5f                   	pop    %edi
  8001a4:	5d                   	pop    %ebp
  8001a5:	c3                   	ret    

008001a6 <sys_page_map>:

int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
  8001a6:	55                   	push   %ebp
  8001a7:	89 e5                	mov    %esp,%ebp
  8001a9:	57                   	push   %edi
  8001aa:	56                   	push   %esi
  8001ab:	53                   	push   %ebx
  8001ac:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001af:	b8 05 00 00 00       	mov    $0x5,%eax
  8001b4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001b7:	8b 55 08             	mov    0x8(%ebp),%edx
  8001ba:	8b 5d 10             	mov    0x10(%ebp),%ebx
  8001bd:	8b 7d 14             	mov    0x14(%ebp),%edi
  8001c0:	8b 75 18             	mov    0x18(%ebp),%esi
  8001c3:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8001c5:	85 c0                	test   %eax,%eax
  8001c7:	7e 17                	jle    8001e0 <sys_page_map+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8001c9:	83 ec 0c             	sub    $0xc,%esp
  8001cc:	50                   	push   %eax
  8001cd:	6a 05                	push   $0x5
  8001cf:	68 ea 1d 80 00       	push   $0x801dea
  8001d4:	6a 23                	push   $0x23
  8001d6:	68 07 1e 80 00       	push   $0x801e07
  8001db:	e8 57 0e 00 00       	call   801037 <_panic>
int
sys_page_map(envid_t srcenv, void *srcva, envid_t dstenv, void *dstva, int perm)
{
	
	return syscall(SYS_page_map, 1, srcenv, (uint32_t) srcva, dstenv, (uint32_t) dstva, perm);
}
  8001e0:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8001e3:	5b                   	pop    %ebx
  8001e4:	5e                   	pop    %esi
  8001e5:	5f                   	pop    %edi
  8001e6:	5d                   	pop    %ebp
  8001e7:	c3                   	ret    

008001e8 <sys_page_unmap>:

int
sys_page_unmap(envid_t envid, void *va)
{
  8001e8:	55                   	push   %ebp
  8001e9:	89 e5                	mov    %esp,%ebp
  8001eb:	57                   	push   %edi
  8001ec:	56                   	push   %esi
  8001ed:	53                   	push   %ebx
  8001ee:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8001f1:	bb 00 00 00 00       	mov    $0x0,%ebx
  8001f6:	b8 06 00 00 00       	mov    $0x6,%eax
  8001fb:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8001fe:	8b 55 08             	mov    0x8(%ebp),%edx
  800201:	89 df                	mov    %ebx,%edi
  800203:	89 de                	mov    %ebx,%esi
  800205:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800207:	85 c0                	test   %eax,%eax
  800209:	7e 17                	jle    800222 <sys_page_unmap+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80020b:	83 ec 0c             	sub    $0xc,%esp
  80020e:	50                   	push   %eax
  80020f:	6a 06                	push   $0x6
  800211:	68 ea 1d 80 00       	push   $0x801dea
  800216:	6a 23                	push   $0x23
  800218:	68 07 1e 80 00       	push   $0x801e07
  80021d:	e8 15 0e 00 00       	call   801037 <_panic>
int
sys_page_unmap(envid_t envid, void *va)
{
	
	return syscall(SYS_page_unmap, 1, envid, (uint32_t) va, 0, 0, 0);
}
  800222:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800225:	5b                   	pop    %ebx
  800226:	5e                   	pop    %esi
  800227:	5f                   	pop    %edi
  800228:	5d                   	pop    %ebp
  800229:	c3                   	ret    

0080022a <sys_env_set_status>:

// sys_exofork is inlined in lib.h

int
sys_env_set_status(envid_t envid, int status)
{
  80022a:	55                   	push   %ebp
  80022b:	89 e5                	mov    %esp,%ebp
  80022d:	57                   	push   %edi
  80022e:	56                   	push   %esi
  80022f:	53                   	push   %ebx
  800230:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800233:	bb 00 00 00 00       	mov    $0x0,%ebx
  800238:	b8 08 00 00 00       	mov    $0x8,%eax
  80023d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800240:	8b 55 08             	mov    0x8(%ebp),%edx
  800243:	89 df                	mov    %ebx,%edi
  800245:	89 de                	mov    %ebx,%esi
  800247:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800249:	85 c0                	test   %eax,%eax
  80024b:	7e 17                	jle    800264 <sys_env_set_status+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80024d:	83 ec 0c             	sub    $0xc,%esp
  800250:	50                   	push   %eax
  800251:	6a 08                	push   $0x8
  800253:	68 ea 1d 80 00       	push   $0x801dea
  800258:	6a 23                	push   $0x23
  80025a:	68 07 1e 80 00       	push   $0x801e07
  80025f:	e8 d3 0d 00 00       	call   801037 <_panic>

int
sys_env_set_status(envid_t envid, int status)
{
	return syscall(SYS_env_set_status, 1, envid, status, 0, 0, 0);
}
  800264:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800267:	5b                   	pop    %ebx
  800268:	5e                   	pop    %esi
  800269:	5f                   	pop    %edi
  80026a:	5d                   	pop    %ebp
  80026b:	c3                   	ret    

0080026c <sys_env_set_trapframe>:

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
  80026c:	55                   	push   %ebp
  80026d:	89 e5                	mov    %esp,%ebp
  80026f:	57                   	push   %edi
  800270:	56                   	push   %esi
  800271:	53                   	push   %ebx
  800272:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  800275:	bb 00 00 00 00       	mov    $0x0,%ebx
  80027a:	b8 09 00 00 00       	mov    $0x9,%eax
  80027f:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800282:	8b 55 08             	mov    0x8(%ebp),%edx
  800285:	89 df                	mov    %ebx,%edi
  800287:	89 de                	mov    %ebx,%esi
  800289:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  80028b:	85 c0                	test   %eax,%eax
  80028d:	7e 17                	jle    8002a6 <sys_env_set_trapframe+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  80028f:	83 ec 0c             	sub    $0xc,%esp
  800292:	50                   	push   %eax
  800293:	6a 09                	push   $0x9
  800295:	68 ea 1d 80 00       	push   $0x801dea
  80029a:	6a 23                	push   $0x23
  80029c:	68 07 1e 80 00       	push   $0x801e07
  8002a1:	e8 91 0d 00 00       	call   801037 <_panic>

int
sys_env_set_trapframe(envid_t envid, struct Trapframe *tf)
{
	return syscall(SYS_env_set_trapframe, 1, envid, (uint32_t) tf, 0, 0, 0);
}
  8002a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002a9:	5b                   	pop    %ebx
  8002aa:	5e                   	pop    %esi
  8002ab:	5f                   	pop    %edi
  8002ac:	5d                   	pop    %ebp
  8002ad:	c3                   	ret    

008002ae <sys_env_set_pgfault_upcall>:

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
  8002ae:	55                   	push   %ebp
  8002af:	89 e5                	mov    %esp,%ebp
  8002b1:	57                   	push   %edi
  8002b2:	56                   	push   %esi
  8002b3:	53                   	push   %ebx
  8002b4:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002b7:	bb 00 00 00 00       	mov    $0x0,%ebx
  8002bc:	b8 0a 00 00 00       	mov    $0xa,%eax
  8002c1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  8002c4:	8b 55 08             	mov    0x8(%ebp),%edx
  8002c7:	89 df                	mov    %ebx,%edi
  8002c9:	89 de                	mov    %ebx,%esi
  8002cb:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  8002cd:	85 c0                	test   %eax,%eax
  8002cf:	7e 17                	jle    8002e8 <sys_env_set_pgfault_upcall+0x3a>
		panic("syscall %d returned %d (> 0)", num, ret);
  8002d1:	83 ec 0c             	sub    $0xc,%esp
  8002d4:	50                   	push   %eax
  8002d5:	6a 0a                	push   $0xa
  8002d7:	68 ea 1d 80 00       	push   $0x801dea
  8002dc:	6a 23                	push   $0x23
  8002de:	68 07 1e 80 00       	push   $0x801e07
  8002e3:	e8 4f 0d 00 00       	call   801037 <_panic>

int
sys_env_set_pgfault_upcall(envid_t envid, void *upcall)
{
	return syscall(SYS_env_set_pgfault_upcall, 1, envid, (uint32_t) upcall, 0, 0, 0);
}
  8002e8:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8002eb:	5b                   	pop    %ebx
  8002ec:	5e                   	pop    %esi
  8002ed:	5f                   	pop    %edi
  8002ee:	5d                   	pop    %ebp
  8002ef:	c3                   	ret    

008002f0 <sys_ipc_try_send>:

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
  8002f0:	55                   	push   %ebp
  8002f1:	89 e5                	mov    %esp,%ebp
  8002f3:	57                   	push   %edi
  8002f4:	56                   	push   %esi
  8002f5:	53                   	push   %ebx
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  8002f6:	be 00 00 00 00       	mov    $0x0,%esi
  8002fb:	b8 0c 00 00 00       	mov    $0xc,%eax
  800300:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800303:	8b 55 08             	mov    0x8(%ebp),%edx
  800306:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800309:	8b 7d 14             	mov    0x14(%ebp),%edi
  80030c:	cd 30                	int    $0x30

int
sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)
{
	return syscall(SYS_ipc_try_send, 0, envid, value, (uint32_t) srcva, perm, 0);
}
  80030e:	5b                   	pop    %ebx
  80030f:	5e                   	pop    %esi
  800310:	5f                   	pop    %edi
  800311:	5d                   	pop    %ebp
  800312:	c3                   	ret    

00800313 <sys_ipc_recv>:

int
sys_ipc_recv(void *dstva)
{
  800313:	55                   	push   %ebp
  800314:	89 e5                	mov    %esp,%ebp
  800316:	57                   	push   %edi
  800317:	56                   	push   %esi
  800318:	53                   	push   %ebx
  800319:	83 ec 0c             	sub    $0xc,%esp
	//
	// The last clause tells the assembler that this can
	// potentially change the condition codes and arbitrary
	// memory locations.
//	panic("SYSCALL: %d\n",a1);
	asm volatile("int %1\n"
  80031c:	b9 00 00 00 00       	mov    $0x0,%ecx
  800321:	b8 0d 00 00 00       	mov    $0xd,%eax
  800326:	8b 55 08             	mov    0x8(%ebp),%edx
  800329:	89 cb                	mov    %ecx,%ebx
  80032b:	89 cf                	mov    %ecx,%edi
  80032d:	89 ce                	mov    %ecx,%esi
  80032f:	cd 30                	int    $0x30
		       "b" (a3),
		       "D" (a4),
		       "S" (a5)
		     : "cc", "memory");
	//cprintf("the sys_call ret is:%d\n",ret);
	if(check && ret > 0)
  800331:	85 c0                	test   %eax,%eax
  800333:	7e 17                	jle    80034c <sys_ipc_recv+0x39>
		panic("syscall %d returned %d (> 0)", num, ret);
  800335:	83 ec 0c             	sub    $0xc,%esp
  800338:	50                   	push   %eax
  800339:	6a 0d                	push   $0xd
  80033b:	68 ea 1d 80 00       	push   $0x801dea
  800340:	6a 23                	push   $0x23
  800342:	68 07 1e 80 00       	push   $0x801e07
  800347:	e8 eb 0c 00 00       	call   801037 <_panic>

int
sys_ipc_recv(void *dstva)
{
	return syscall(SYS_ipc_recv, 1, (uint32_t)dstva, 0, 0, 0, 0);
}
  80034c:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80034f:	5b                   	pop    %ebx
  800350:	5e                   	pop    %esi
  800351:	5f                   	pop    %edi
  800352:	5d                   	pop    %ebp
  800353:	c3                   	ret    

00800354 <fd2num>:
// File descriptor manipulators
// --------------------------------------------------------------

int
fd2num(struct Fd *fd)
{
  800354:	55                   	push   %ebp
  800355:	89 e5                	mov    %esp,%ebp
	return ((uintptr_t) fd - FDTABLE) / PGSIZE;
  800357:	8b 45 08             	mov    0x8(%ebp),%eax
  80035a:	05 00 00 00 30       	add    $0x30000000,%eax
  80035f:	c1 e8 0c             	shr    $0xc,%eax
}
  800362:	5d                   	pop    %ebp
  800363:	c3                   	ret    

00800364 <fd2data>:

char*
fd2data(struct Fd *fd)
{
  800364:	55                   	push   %ebp
  800365:	89 e5                	mov    %esp,%ebp
	return INDEX2DATA(fd2num(fd));
  800367:	8b 45 08             	mov    0x8(%ebp),%eax
  80036a:	05 00 00 00 30       	add    $0x30000000,%eax
  80036f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  800374:	2d 00 00 fe 2f       	sub    $0x2ffe0000,%eax
}
  800379:	5d                   	pop    %ebp
  80037a:	c3                   	ret    

0080037b <fd_alloc>:
// Returns 0 on success, < 0 on error.  Errors are:
//	-E_MAX_FD: no more file descriptors
// On error, *fd_store is set to 0.
int
fd_alloc(struct Fd **fd_store)
{
  80037b:	55                   	push   %ebp
  80037c:	89 e5                	mov    %esp,%ebp
  80037e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800381:	b8 00 00 00 d0       	mov    $0xd0000000,%eax
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
		fd = INDEX2FD(i);
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
  800386:	89 c2                	mov    %eax,%edx
  800388:	c1 ea 16             	shr    $0x16,%edx
  80038b:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  800392:	f6 c2 01             	test   $0x1,%dl
  800395:	74 11                	je     8003a8 <fd_alloc+0x2d>
  800397:	89 c2                	mov    %eax,%edx
  800399:	c1 ea 0c             	shr    $0xc,%edx
  80039c:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003a3:	f6 c2 01             	test   $0x1,%dl
  8003a6:	75 09                	jne    8003b1 <fd_alloc+0x36>
			*fd_store = fd;
  8003a8:	89 01                	mov    %eax,(%ecx)
			return 0;
  8003aa:	b8 00 00 00 00       	mov    $0x0,%eax
  8003af:	eb 17                	jmp    8003c8 <fd_alloc+0x4d>
  8003b1:	05 00 10 00 00       	add    $0x1000,%eax
fd_alloc(struct Fd **fd_store)
{
	int i;
	struct Fd *fd;

	for (i = 0; i < MAXFD; i++) {
  8003b6:	3d 00 00 02 d0       	cmp    $0xd0020000,%eax
  8003bb:	75 c9                	jne    800386 <fd_alloc+0xb>
		if ((uvpd[PDX(fd)] & PTE_P) == 0 || (uvpt[PGNUM(fd)] & PTE_P) == 0) {
			*fd_store = fd;
			return 0;
		}
	}
	*fd_store = 0;
  8003bd:	c7 01 00 00 00 00    	movl   $0x0,(%ecx)
	return -E_MAX_OPEN;
  8003c3:	b8 f6 ff ff ff       	mov    $0xfffffff6,%eax
}
  8003c8:	5d                   	pop    %ebp
  8003c9:	c3                   	ret    

008003ca <fd_lookup>:
// Returns 0 on success (the page is in range and mapped), < 0 on error.
// Errors are:
//	-E_INVAL: fdnum was either not in range or not mapped.
int
fd_lookup(int fdnum, struct Fd **fd_store)
{
  8003ca:	55                   	push   %ebp
  8003cb:	89 e5                	mov    %esp,%ebp
  8003cd:	8b 45 08             	mov    0x8(%ebp),%eax
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
  8003d0:	83 f8 1f             	cmp    $0x1f,%eax
  8003d3:	77 36                	ja     80040b <fd_lookup+0x41>
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	fd = INDEX2FD(fdnum);
  8003d5:	c1 e0 0c             	shl    $0xc,%eax
  8003d8:	2d 00 00 00 30       	sub    $0x30000000,%eax
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
  8003dd:	89 c2                	mov    %eax,%edx
  8003df:	c1 ea 16             	shr    $0x16,%edx
  8003e2:	8b 14 95 00 d0 7b ef 	mov    -0x10843000(,%edx,4),%edx
  8003e9:	f6 c2 01             	test   $0x1,%dl
  8003ec:	74 24                	je     800412 <fd_lookup+0x48>
  8003ee:	89 c2                	mov    %eax,%edx
  8003f0:	c1 ea 0c             	shr    $0xc,%edx
  8003f3:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
  8003fa:	f6 c2 01             	test   $0x1,%dl
  8003fd:	74 1a                	je     800419 <fd_lookup+0x4f>
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	*fd_store = fd;
  8003ff:	8b 55 0c             	mov    0xc(%ebp),%edx
  800402:	89 02                	mov    %eax,(%edx)
	return 0;
  800404:	b8 00 00 00 00       	mov    $0x0,%eax
  800409:	eb 13                	jmp    80041e <fd_lookup+0x54>
	struct Fd *fd;

	if (fdnum < 0 || fdnum >= MAXFD) {
		if (debug)
			cprintf("[%08x] bad fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  80040b:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800410:	eb 0c                	jmp    80041e <fd_lookup+0x54>
	}
	fd = INDEX2FD(fdnum);
	if (!(uvpd[PDX(fd)] & PTE_P) || !(uvpt[PGNUM(fd)] & PTE_P)) {
		if (debug)
			cprintf("[%08x] closed fd %d\n", thisenv->env_id, fdnum);
		return -E_INVAL;
  800412:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
  800417:	eb 05                	jmp    80041e <fd_lookup+0x54>
  800419:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
	}
	*fd_store = fd;
	return 0;
}
  80041e:	5d                   	pop    %ebp
  80041f:	c3                   	ret    

00800420 <dev_lookup>:
	0
};

int
dev_lookup(int dev_id, struct Dev **dev)
{
  800420:	55                   	push   %ebp
  800421:	89 e5                	mov    %esp,%ebp
  800423:	83 ec 08             	sub    $0x8,%esp
  800426:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800429:	ba 94 1e 80 00       	mov    $0x801e94,%edx
	int i;
	for (i = 0; devtab[i]; i++)
  80042e:	eb 13                	jmp    800443 <dev_lookup+0x23>
  800430:	83 c2 04             	add    $0x4,%edx
		if (devtab[i]->dev_id == dev_id) {
  800433:	39 08                	cmp    %ecx,(%eax)
  800435:	75 0c                	jne    800443 <dev_lookup+0x23>
			*dev = devtab[i];
  800437:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80043a:	89 01                	mov    %eax,(%ecx)
			return 0;
  80043c:	b8 00 00 00 00       	mov    $0x0,%eax
  800441:	eb 2e                	jmp    800471 <dev_lookup+0x51>

int
dev_lookup(int dev_id, struct Dev **dev)
{
	int i;
	for (i = 0; devtab[i]; i++)
  800443:	8b 02                	mov    (%edx),%eax
  800445:	85 c0                	test   %eax,%eax
  800447:	75 e7                	jne    800430 <dev_lookup+0x10>
		if (devtab[i]->dev_id == dev_id) {
			*dev = devtab[i];
			return 0;
		}
	cprintf("[%08x] unknown device type %d\n", thisenv->env_id, dev_id);
  800449:	a1 04 40 80 00       	mov    0x804004,%eax
  80044e:	8b 40 48             	mov    0x48(%eax),%eax
  800451:	83 ec 04             	sub    $0x4,%esp
  800454:	51                   	push   %ecx
  800455:	50                   	push   %eax
  800456:	68 18 1e 80 00       	push   $0x801e18
  80045b:	e8 b0 0c 00 00       	call   801110 <cprintf>
	*dev = 0;
  800460:	8b 45 0c             	mov    0xc(%ebp),%eax
  800463:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
	return -E_INVAL;
  800469:	83 c4 10             	add    $0x10,%esp
  80046c:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax
}
  800471:	c9                   	leave  
  800472:	c3                   	ret    

00800473 <fd_close>:
// If 'must_exist' is 1, then fd_close returns -E_INVAL when passed a
// closed or nonexistent file descriptor.
// Returns 0 on success, < 0 on error.
int
fd_close(struct Fd *fd, bool must_exist)
{
  800473:	55                   	push   %ebp
  800474:	89 e5                	mov    %esp,%ebp
  800476:	56                   	push   %esi
  800477:	53                   	push   %ebx
  800478:	83 ec 10             	sub    $0x10,%esp
  80047b:	8b 75 08             	mov    0x8(%ebp),%esi
  80047e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Fd *fd2;
	struct Dev *dev;
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
  800481:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800484:	50                   	push   %eax
  800485:	8d 86 00 00 00 30    	lea    0x30000000(%esi),%eax
  80048b:	c1 e8 0c             	shr    $0xc,%eax
  80048e:	50                   	push   %eax
  80048f:	e8 36 ff ff ff       	call   8003ca <fd_lookup>
  800494:	83 c4 08             	add    $0x8,%esp
  800497:	85 c0                	test   %eax,%eax
  800499:	78 05                	js     8004a0 <fd_close+0x2d>
	    || fd != fd2)
  80049b:	3b 75 f4             	cmp    -0xc(%ebp),%esi
  80049e:	74 0c                	je     8004ac <fd_close+0x39>
		return (must_exist ? r : 0);
  8004a0:	84 db                	test   %bl,%bl
  8004a2:	ba 00 00 00 00       	mov    $0x0,%edx
  8004a7:	0f 44 c2             	cmove  %edx,%eax
  8004aa:	eb 41                	jmp    8004ed <fd_close+0x7a>
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
  8004ac:	83 ec 08             	sub    $0x8,%esp
  8004af:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8004b2:	50                   	push   %eax
  8004b3:	ff 36                	pushl  (%esi)
  8004b5:	e8 66 ff ff ff       	call   800420 <dev_lookup>
  8004ba:	89 c3                	mov    %eax,%ebx
  8004bc:	83 c4 10             	add    $0x10,%esp
  8004bf:	85 c0                	test   %eax,%eax
  8004c1:	78 1a                	js     8004dd <fd_close+0x6a>
		if (dev->dev_close)
  8004c3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8004c6:	8b 40 10             	mov    0x10(%eax),%eax
			r = (*dev->dev_close)(fd);
		else
			r = 0;
  8004c9:	bb 00 00 00 00       	mov    $0x0,%ebx
	int r;
	if ((r = fd_lookup(fd2num(fd), &fd2)) < 0
	    || fd != fd2)
		return (must_exist ? r : 0);
	if ((r = dev_lookup(fd->fd_dev_id, &dev)) >= 0) {
		if (dev->dev_close)
  8004ce:	85 c0                	test   %eax,%eax
  8004d0:	74 0b                	je     8004dd <fd_close+0x6a>
			r = (*dev->dev_close)(fd);
  8004d2:	83 ec 0c             	sub    $0xc,%esp
  8004d5:	56                   	push   %esi
  8004d6:	ff d0                	call   *%eax
  8004d8:	89 c3                	mov    %eax,%ebx
  8004da:	83 c4 10             	add    $0x10,%esp
		else
			r = 0;
	}
	// Make sure fd is unmapped.  Might be a no-op if
	// (*dev->dev_close)(fd) already unmapped it.
	(void) sys_page_unmap(0, fd);
  8004dd:	83 ec 08             	sub    $0x8,%esp
  8004e0:	56                   	push   %esi
  8004e1:	6a 00                	push   $0x0
  8004e3:	e8 00 fd ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  8004e8:	83 c4 10             	add    $0x10,%esp
  8004eb:	89 d8                	mov    %ebx,%eax
}
  8004ed:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8004f0:	5b                   	pop    %ebx
  8004f1:	5e                   	pop    %esi
  8004f2:	5d                   	pop    %ebp
  8004f3:	c3                   	ret    

008004f4 <close>:
	return -E_INVAL;
}

int
close(int fdnum)
{
  8004f4:	55                   	push   %ebp
  8004f5:	89 e5                	mov    %esp,%ebp
  8004f7:	83 ec 18             	sub    $0x18,%esp
	struct Fd *fd;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  8004fa:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8004fd:	50                   	push   %eax
  8004fe:	ff 75 08             	pushl  0x8(%ebp)
  800501:	e8 c4 fe ff ff       	call   8003ca <fd_lookup>
  800506:	83 c4 08             	add    $0x8,%esp
  800509:	85 c0                	test   %eax,%eax
  80050b:	78 10                	js     80051d <close+0x29>
		return r;
	else
		return fd_close(fd, 1);
  80050d:	83 ec 08             	sub    $0x8,%esp
  800510:	6a 01                	push   $0x1
  800512:	ff 75 f4             	pushl  -0xc(%ebp)
  800515:	e8 59 ff ff ff       	call   800473 <fd_close>
  80051a:	83 c4 10             	add    $0x10,%esp
}
  80051d:	c9                   	leave  
  80051e:	c3                   	ret    

0080051f <close_all>:

void
close_all(void)
{
  80051f:	55                   	push   %ebp
  800520:	89 e5                	mov    %esp,%ebp
  800522:	53                   	push   %ebx
  800523:	83 ec 04             	sub    $0x4,%esp
	int i;
	for (i = 0; i < MAXFD; i++)
  800526:	bb 00 00 00 00       	mov    $0x0,%ebx
		close(i);
  80052b:	83 ec 0c             	sub    $0xc,%esp
  80052e:	53                   	push   %ebx
  80052f:	e8 c0 ff ff ff       	call   8004f4 <close>

void
close_all(void)
{
	int i;
	for (i = 0; i < MAXFD; i++)
  800534:	83 c3 01             	add    $0x1,%ebx
  800537:	83 c4 10             	add    $0x10,%esp
  80053a:	83 fb 20             	cmp    $0x20,%ebx
  80053d:	75 ec                	jne    80052b <close_all+0xc>
		close(i);
}
  80053f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800542:	c9                   	leave  
  800543:	c3                   	ret    

00800544 <dup>:
// file and the file offset of the other.
// Closes any previously open file descriptor at 'newfdnum'.
// This is implemented using virtual memory tricks (of course!).
int
dup(int oldfdnum, int newfdnum)
{
  800544:	55                   	push   %ebp
  800545:	89 e5                	mov    %esp,%ebp
  800547:	57                   	push   %edi
  800548:	56                   	push   %esi
  800549:	53                   	push   %ebx
  80054a:	83 ec 2c             	sub    $0x2c,%esp
  80054d:	8b 75 0c             	mov    0xc(%ebp),%esi
	int r;
	char *ova, *nva;
	pte_t pte;
	struct Fd *oldfd, *newfd;

	if ((r = fd_lookup(oldfdnum, &oldfd)) < 0)
  800550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  800553:	50                   	push   %eax
  800554:	ff 75 08             	pushl  0x8(%ebp)
  800557:	e8 6e fe ff ff       	call   8003ca <fd_lookup>
  80055c:	83 c4 08             	add    $0x8,%esp
  80055f:	85 c0                	test   %eax,%eax
  800561:	0f 88 c1 00 00 00    	js     800628 <dup+0xe4>
		return r;
	close(newfdnum);
  800567:	83 ec 0c             	sub    $0xc,%esp
  80056a:	56                   	push   %esi
  80056b:	e8 84 ff ff ff       	call   8004f4 <close>

	newfd = INDEX2FD(newfdnum);
  800570:	89 f3                	mov    %esi,%ebx
  800572:	c1 e3 0c             	shl    $0xc,%ebx
  800575:	81 eb 00 00 00 30    	sub    $0x30000000,%ebx
	ova = fd2data(oldfd);
  80057b:	83 c4 04             	add    $0x4,%esp
  80057e:	ff 75 e4             	pushl  -0x1c(%ebp)
  800581:	e8 de fd ff ff       	call   800364 <fd2data>
  800586:	89 c7                	mov    %eax,%edi
	nva = fd2data(newfd);
  800588:	89 1c 24             	mov    %ebx,(%esp)
  80058b:	e8 d4 fd ff ff       	call   800364 <fd2data>
  800590:	83 c4 10             	add    $0x10,%esp
  800593:	89 45 d4             	mov    %eax,-0x2c(%ebp)

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
  800596:	89 f8                	mov    %edi,%eax
  800598:	c1 e8 16             	shr    $0x16,%eax
  80059b:	8b 04 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%eax
  8005a2:	a8 01                	test   $0x1,%al
  8005a4:	74 37                	je     8005dd <dup+0x99>
  8005a6:	89 f8                	mov    %edi,%eax
  8005a8:	c1 e8 0c             	shr    $0xc,%eax
  8005ab:	8b 14 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%edx
  8005b2:	f6 c2 01             	test   $0x1,%dl
  8005b5:	74 26                	je     8005dd <dup+0x99>
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
  8005b7:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005be:	83 ec 0c             	sub    $0xc,%esp
  8005c1:	25 07 0e 00 00       	and    $0xe07,%eax
  8005c6:	50                   	push   %eax
  8005c7:	ff 75 d4             	pushl  -0x2c(%ebp)
  8005ca:	6a 00                	push   $0x0
  8005cc:	57                   	push   %edi
  8005cd:	6a 00                	push   $0x0
  8005cf:	e8 d2 fb ff ff       	call   8001a6 <sys_page_map>
  8005d4:	89 c7                	mov    %eax,%edi
  8005d6:	83 c4 20             	add    $0x20,%esp
  8005d9:	85 c0                	test   %eax,%eax
  8005db:	78 2e                	js     80060b <dup+0xc7>
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  8005dd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  8005e0:	89 d0                	mov    %edx,%eax
  8005e2:	c1 e8 0c             	shr    $0xc,%eax
  8005e5:	8b 04 85 00 00 40 ef 	mov    -0x10c00000(,%eax,4),%eax
  8005ec:	83 ec 0c             	sub    $0xc,%esp
  8005ef:	25 07 0e 00 00       	and    $0xe07,%eax
  8005f4:	50                   	push   %eax
  8005f5:	53                   	push   %ebx
  8005f6:	6a 00                	push   $0x0
  8005f8:	52                   	push   %edx
  8005f9:	6a 00                	push   $0x0
  8005fb:	e8 a6 fb ff ff       	call   8001a6 <sys_page_map>
  800600:	89 c7                	mov    %eax,%edi
  800602:	83 c4 20             	add    $0x20,%esp
		goto err;

	return newfdnum;
  800605:	89 f0                	mov    %esi,%eax
	nva = fd2data(newfd);

	if ((uvpd[PDX(ova)] & PTE_P) && (uvpt[PGNUM(ova)] & PTE_P))
		if ((r = sys_page_map(0, ova, 0, nva, uvpt[PGNUM(ova)] & PTE_SYSCALL)) < 0)
			goto err;
	if ((r = sys_page_map(0, oldfd, 0, newfd, uvpt[PGNUM(oldfd)] & PTE_SYSCALL)) < 0)
  800607:	85 ff                	test   %edi,%edi
  800609:	79 1d                	jns    800628 <dup+0xe4>
		goto err;

	return newfdnum;

err:
	sys_page_unmap(0, newfd);
  80060b:	83 ec 08             	sub    $0x8,%esp
  80060e:	53                   	push   %ebx
  80060f:	6a 00                	push   $0x0
  800611:	e8 d2 fb ff ff       	call   8001e8 <sys_page_unmap>
	sys_page_unmap(0, nva);
  800616:	83 c4 08             	add    $0x8,%esp
  800619:	ff 75 d4             	pushl  -0x2c(%ebp)
  80061c:	6a 00                	push   $0x0
  80061e:	e8 c5 fb ff ff       	call   8001e8 <sys_page_unmap>
	return r;
  800623:	83 c4 10             	add    $0x10,%esp
  800626:	89 f8                	mov    %edi,%eax
}
  800628:	8d 65 f4             	lea    -0xc(%ebp),%esp
  80062b:	5b                   	pop    %ebx
  80062c:	5e                   	pop    %esi
  80062d:	5f                   	pop    %edi
  80062e:	5d                   	pop    %ebp
  80062f:	c3                   	ret    

00800630 <read>:

ssize_t
read(int fdnum, void *buf, size_t n)
{
  800630:	55                   	push   %ebp
  800631:	89 e5                	mov    %esp,%ebp
  800633:	53                   	push   %ebx
  800634:	83 ec 14             	sub    $0x14,%esp
  800637:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  80063a:	8d 45 f0             	lea    -0x10(%ebp),%eax
  80063d:	50                   	push   %eax
  80063e:	53                   	push   %ebx
  80063f:	e8 86 fd ff ff       	call   8003ca <fd_lookup>
  800644:	83 c4 08             	add    $0x8,%esp
  800647:	89 c2                	mov    %eax,%edx
  800649:	85 c0                	test   %eax,%eax
  80064b:	78 6d                	js     8006ba <read+0x8a>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  80064d:	83 ec 08             	sub    $0x8,%esp
  800650:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800653:	50                   	push   %eax
  800654:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800657:	ff 30                	pushl  (%eax)
  800659:	e8 c2 fd ff ff       	call   800420 <dev_lookup>
  80065e:	83 c4 10             	add    $0x10,%esp
  800661:	85 c0                	test   %eax,%eax
  800663:	78 4c                	js     8006b1 <read+0x81>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
  800665:	8b 55 f0             	mov    -0x10(%ebp),%edx
  800668:	8b 42 08             	mov    0x8(%edx),%eax
  80066b:	83 e0 03             	and    $0x3,%eax
  80066e:	83 f8 01             	cmp    $0x1,%eax
  800671:	75 21                	jne    800694 <read+0x64>
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
  800673:	a1 04 40 80 00       	mov    0x804004,%eax
  800678:	8b 40 48             	mov    0x48(%eax),%eax
  80067b:	83 ec 04             	sub    $0x4,%esp
  80067e:	53                   	push   %ebx
  80067f:	50                   	push   %eax
  800680:	68 59 1e 80 00       	push   $0x801e59
  800685:	e8 86 0a 00 00       	call   801110 <cprintf>
		return -E_INVAL;
  80068a:	83 c4 10             	add    $0x10,%esp
  80068d:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800692:	eb 26                	jmp    8006ba <read+0x8a>
	}
	if (!dev->dev_read)
  800694:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800697:	8b 40 08             	mov    0x8(%eax),%eax
  80069a:	85 c0                	test   %eax,%eax
  80069c:	74 17                	je     8006b5 <read+0x85>
		return -E_NOT_SUPP;
	return (*dev->dev_read)(fd, buf, n);
  80069e:	83 ec 04             	sub    $0x4,%esp
  8006a1:	ff 75 10             	pushl  0x10(%ebp)
  8006a4:	ff 75 0c             	pushl  0xc(%ebp)
  8006a7:	52                   	push   %edx
  8006a8:	ff d0                	call   *%eax
  8006aa:	89 c2                	mov    %eax,%edx
  8006ac:	83 c4 10             	add    $0x10,%esp
  8006af:	eb 09                	jmp    8006ba <read+0x8a>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8006b1:	89 c2                	mov    %eax,%edx
  8006b3:	eb 05                	jmp    8006ba <read+0x8a>
	if ((fd->fd_omode & O_ACCMODE) == O_WRONLY) {
		cprintf("[%08x] read %d -- bad mode\n", thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_read)
		return -E_NOT_SUPP;
  8006b5:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_read)(fd, buf, n);
}
  8006ba:	89 d0                	mov    %edx,%eax
  8006bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8006bf:	c9                   	leave  
  8006c0:	c3                   	ret    

008006c1 <readn>:

ssize_t
readn(int fdnum, void *buf, size_t n)
{
  8006c1:	55                   	push   %ebp
  8006c2:	89 e5                	mov    %esp,%ebp
  8006c4:	57                   	push   %edi
  8006c5:	56                   	push   %esi
  8006c6:	53                   	push   %ebx
  8006c7:	83 ec 0c             	sub    $0xc,%esp
  8006ca:	8b 7d 08             	mov    0x8(%ebp),%edi
  8006cd:	8b 75 10             	mov    0x10(%ebp),%esi
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006d0:	bb 00 00 00 00       	mov    $0x0,%ebx
  8006d5:	eb 21                	jmp    8006f8 <readn+0x37>
		m = read(fdnum, (char*)buf + tot, n - tot);
  8006d7:	83 ec 04             	sub    $0x4,%esp
  8006da:	89 f0                	mov    %esi,%eax
  8006dc:	29 d8                	sub    %ebx,%eax
  8006de:	50                   	push   %eax
  8006df:	89 d8                	mov    %ebx,%eax
  8006e1:	03 45 0c             	add    0xc(%ebp),%eax
  8006e4:	50                   	push   %eax
  8006e5:	57                   	push   %edi
  8006e6:	e8 45 ff ff ff       	call   800630 <read>
		if (m < 0)
  8006eb:	83 c4 10             	add    $0x10,%esp
  8006ee:	85 c0                	test   %eax,%eax
  8006f0:	78 10                	js     800702 <readn+0x41>
			return m;
		if (m == 0)
  8006f2:	85 c0                	test   %eax,%eax
  8006f4:	74 0a                	je     800700 <readn+0x3f>
ssize_t
readn(int fdnum, void *buf, size_t n)
{
	int m, tot;

	for (tot = 0; tot < n; tot += m) {
  8006f6:	01 c3                	add    %eax,%ebx
  8006f8:	39 f3                	cmp    %esi,%ebx
  8006fa:	72 db                	jb     8006d7 <readn+0x16>
  8006fc:	89 d8                	mov    %ebx,%eax
  8006fe:	eb 02                	jmp    800702 <readn+0x41>
  800700:	89 d8                	mov    %ebx,%eax
			return m;
		if (m == 0)
			break;
	}
	return tot;
}
  800702:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800705:	5b                   	pop    %ebx
  800706:	5e                   	pop    %esi
  800707:	5f                   	pop    %edi
  800708:	5d                   	pop    %ebp
  800709:	c3                   	ret    

0080070a <write>:

ssize_t
write(int fdnum, const void *buf, size_t n)
{
  80070a:	55                   	push   %ebp
  80070b:	89 e5                	mov    %esp,%ebp
  80070d:	53                   	push   %ebx
  80070e:	83 ec 14             	sub    $0x14,%esp
  800711:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800714:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800717:	50                   	push   %eax
  800718:	53                   	push   %ebx
  800719:	e8 ac fc ff ff       	call   8003ca <fd_lookup>
  80071e:	83 c4 08             	add    $0x8,%esp
  800721:	89 c2                	mov    %eax,%edx
  800723:	85 c0                	test   %eax,%eax
  800725:	78 68                	js     80078f <write+0x85>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800727:	83 ec 08             	sub    $0x8,%esp
  80072a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80072d:	50                   	push   %eax
  80072e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800731:	ff 30                	pushl  (%eax)
  800733:	e8 e8 fc ff ff       	call   800420 <dev_lookup>
  800738:	83 c4 10             	add    $0x10,%esp
  80073b:	85 c0                	test   %eax,%eax
  80073d:	78 47                	js     800786 <write+0x7c>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  80073f:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800742:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  800746:	75 21                	jne    800769 <write+0x5f>
		cprintf("[%08x] write %d -- bad mode\n", thisenv->env_id, fdnum);
  800748:	a1 04 40 80 00       	mov    0x804004,%eax
  80074d:	8b 40 48             	mov    0x48(%eax),%eax
  800750:	83 ec 04             	sub    $0x4,%esp
  800753:	53                   	push   %ebx
  800754:	50                   	push   %eax
  800755:	68 75 1e 80 00       	push   $0x801e75
  80075a:	e8 b1 09 00 00       	call   801110 <cprintf>
		return -E_INVAL;
  80075f:	83 c4 10             	add    $0x10,%esp
  800762:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  800767:	eb 26                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
  800769:	8b 55 f4             	mov    -0xc(%ebp),%edx
  80076c:	8b 52 0c             	mov    0xc(%edx),%edx
  80076f:	85 d2                	test   %edx,%edx
  800771:	74 17                	je     80078a <write+0x80>
		return -E_NOT_SUPP;
	return (*dev->dev_write)(fd, buf, n);
  800773:	83 ec 04             	sub    $0x4,%esp
  800776:	ff 75 10             	pushl  0x10(%ebp)
  800779:	ff 75 0c             	pushl  0xc(%ebp)
  80077c:	50                   	push   %eax
  80077d:	ff d2                	call   *%edx
  80077f:	89 c2                	mov    %eax,%edx
  800781:	83 c4 10             	add    $0x10,%esp
  800784:	eb 09                	jmp    80078f <write+0x85>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800786:	89 c2                	mov    %eax,%edx
  800788:	eb 05                	jmp    80078f <write+0x85>
	}
	if (debug)
		cprintf("write %d %p %d via dev %s\n",
			fdnum, buf, n, dev->dev_name);
	if (!dev->dev_write)
		return -E_NOT_SUPP;
  80078a:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_write)(fd, buf, n);
}
  80078f:	89 d0                	mov    %edx,%eax
  800791:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800794:	c9                   	leave  
  800795:	c3                   	ret    

00800796 <seek>:

int
seek(int fdnum, off_t offset)
{
  800796:	55                   	push   %ebp
  800797:	89 e5                	mov    %esp,%ebp
  800799:	83 ec 10             	sub    $0x10,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  80079c:	8d 45 fc             	lea    -0x4(%ebp),%eax
  80079f:	50                   	push   %eax
  8007a0:	ff 75 08             	pushl  0x8(%ebp)
  8007a3:	e8 22 fc ff ff       	call   8003ca <fd_lookup>
  8007a8:	83 c4 08             	add    $0x8,%esp
  8007ab:	85 c0                	test   %eax,%eax
  8007ad:	78 0e                	js     8007bd <seek+0x27>
		return r;
	fd->fd_offset = offset;
  8007af:	8b 45 fc             	mov    -0x4(%ebp),%eax
  8007b2:	8b 55 0c             	mov    0xc(%ebp),%edx
  8007b5:	89 50 04             	mov    %edx,0x4(%eax)
	return 0;
  8007b8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8007bd:	c9                   	leave  
  8007be:	c3                   	ret    

008007bf <ftruncate>:

int
ftruncate(int fdnum, off_t newsize)
{
  8007bf:	55                   	push   %ebp
  8007c0:	89 e5                	mov    %esp,%ebp
  8007c2:	53                   	push   %ebx
  8007c3:	83 ec 14             	sub    $0x14,%esp
  8007c6:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
  8007c9:	8d 45 f0             	lea    -0x10(%ebp),%eax
  8007cc:	50                   	push   %eax
  8007cd:	53                   	push   %ebx
  8007ce:	e8 f7 fb ff ff       	call   8003ca <fd_lookup>
  8007d3:	83 c4 08             	add    $0x8,%esp
  8007d6:	89 c2                	mov    %eax,%edx
  8007d8:	85 c0                	test   %eax,%eax
  8007da:	78 65                	js     800841 <ftruncate+0x82>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8007dc:	83 ec 08             	sub    $0x8,%esp
  8007df:	8d 45 f4             	lea    -0xc(%ebp),%eax
  8007e2:	50                   	push   %eax
  8007e3:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007e6:	ff 30                	pushl  (%eax)
  8007e8:	e8 33 fc ff ff       	call   800420 <dev_lookup>
  8007ed:	83 c4 10             	add    $0x10,%esp
  8007f0:	85 c0                	test   %eax,%eax
  8007f2:	78 44                	js     800838 <ftruncate+0x79>
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
  8007f4:	8b 45 f0             	mov    -0x10(%ebp),%eax
  8007f7:	f6 40 08 03          	testb  $0x3,0x8(%eax)
  8007fb:	75 21                	jne    80081e <ftruncate+0x5f>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
  8007fd:	a1 04 40 80 00       	mov    0x804004,%eax
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
		return r;
	if ((fd->fd_omode & O_ACCMODE) == O_RDONLY) {
		cprintf("[%08x] ftruncate %d -- bad mode\n",
  800802:	8b 40 48             	mov    0x48(%eax),%eax
  800805:	83 ec 04             	sub    $0x4,%esp
  800808:	53                   	push   %ebx
  800809:	50                   	push   %eax
  80080a:	68 38 1e 80 00       	push   $0x801e38
  80080f:	e8 fc 08 00 00       	call   801110 <cprintf>
			thisenv->env_id, fdnum);
		return -E_INVAL;
  800814:	83 c4 10             	add    $0x10,%esp
  800817:	ba fd ff ff ff       	mov    $0xfffffffd,%edx
  80081c:	eb 23                	jmp    800841 <ftruncate+0x82>
	}
	if (!dev->dev_trunc)
  80081e:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800821:	8b 52 18             	mov    0x18(%edx),%edx
  800824:	85 d2                	test   %edx,%edx
  800826:	74 14                	je     80083c <ftruncate+0x7d>
		return -E_NOT_SUPP;
	return (*dev->dev_trunc)(fd, newsize);
  800828:	83 ec 08             	sub    $0x8,%esp
  80082b:	ff 75 0c             	pushl  0xc(%ebp)
  80082e:	50                   	push   %eax
  80082f:	ff d2                	call   *%edx
  800831:	89 c2                	mov    %eax,%edx
  800833:	83 c4 10             	add    $0x10,%esp
  800836:	eb 09                	jmp    800841 <ftruncate+0x82>
{
	int r;
	struct Dev *dev;
	struct Fd *fd;
	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800838:	89 c2                	mov    %eax,%edx
  80083a:	eb 05                	jmp    800841 <ftruncate+0x82>
		cprintf("[%08x] ftruncate %d -- bad mode\n",
			thisenv->env_id, fdnum);
		return -E_INVAL;
	}
	if (!dev->dev_trunc)
		return -E_NOT_SUPP;
  80083c:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	return (*dev->dev_trunc)(fd, newsize);
}
  800841:	89 d0                	mov    %edx,%eax
  800843:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800846:	c9                   	leave  
  800847:	c3                   	ret    

00800848 <fstat>:

int
fstat(int fdnum, struct Stat *stat)
{
  800848:	55                   	push   %ebp
  800849:	89 e5                	mov    %esp,%ebp
  80084b:	53                   	push   %ebx
  80084c:	83 ec 14             	sub    $0x14,%esp
  80084f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
  800852:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800855:	50                   	push   %eax
  800856:	ff 75 08             	pushl  0x8(%ebp)
  800859:	e8 6c fb ff ff       	call   8003ca <fd_lookup>
  80085e:	83 c4 08             	add    $0x8,%esp
  800861:	89 c2                	mov    %eax,%edx
  800863:	85 c0                	test   %eax,%eax
  800865:	78 58                	js     8008bf <fstat+0x77>
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  800867:	83 ec 08             	sub    $0x8,%esp
  80086a:	8d 45 f4             	lea    -0xc(%ebp),%eax
  80086d:	50                   	push   %eax
  80086e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800871:	ff 30                	pushl  (%eax)
  800873:	e8 a8 fb ff ff       	call   800420 <dev_lookup>
  800878:	83 c4 10             	add    $0x10,%esp
  80087b:	85 c0                	test   %eax,%eax
  80087d:	78 37                	js     8008b6 <fstat+0x6e>
		return r;
	if (!dev->dev_stat)
  80087f:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800882:	83 78 14 00          	cmpl   $0x0,0x14(%eax)
  800886:	74 32                	je     8008ba <fstat+0x72>
		return -E_NOT_SUPP;
	stat->st_name[0] = 0;
  800888:	c6 03 00             	movb   $0x0,(%ebx)
	stat->st_size = 0;
  80088b:	c7 83 80 00 00 00 00 	movl   $0x0,0x80(%ebx)
  800892:	00 00 00 
	stat->st_isdir = 0;
  800895:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  80089c:	00 00 00 
	stat->st_dev = dev;
  80089f:	89 83 88 00 00 00    	mov    %eax,0x88(%ebx)
	return (*dev->dev_stat)(fd, stat);
  8008a5:	83 ec 08             	sub    $0x8,%esp
  8008a8:	53                   	push   %ebx
  8008a9:	ff 75 f0             	pushl  -0x10(%ebp)
  8008ac:	ff 50 14             	call   *0x14(%eax)
  8008af:	89 c2                	mov    %eax,%edx
  8008b1:	83 c4 10             	add    $0x10,%esp
  8008b4:	eb 09                	jmp    8008bf <fstat+0x77>
	int r;
	struct Dev *dev;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0
	    || (r = dev_lookup(fd->fd_dev_id, &dev)) < 0)
  8008b6:	89 c2                	mov    %eax,%edx
  8008b8:	eb 05                	jmp    8008bf <fstat+0x77>
		return r;
	if (!dev->dev_stat)
		return -E_NOT_SUPP;
  8008ba:	ba f1 ff ff ff       	mov    $0xfffffff1,%edx
	stat->st_name[0] = 0;
	stat->st_size = 0;
	stat->st_isdir = 0;
	stat->st_dev = dev;
	return (*dev->dev_stat)(fd, stat);
}
  8008bf:	89 d0                	mov    %edx,%eax
  8008c1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8008c4:	c9                   	leave  
  8008c5:	c3                   	ret    

008008c6 <stat>:

int
stat(const char *path, struct Stat *stat)
{
  8008c6:	55                   	push   %ebp
  8008c7:	89 e5                	mov    %esp,%ebp
  8008c9:	56                   	push   %esi
  8008ca:	53                   	push   %ebx
	int fd, r;

	if ((fd = open(path, O_RDONLY)) < 0)
  8008cb:	83 ec 08             	sub    $0x8,%esp
  8008ce:	6a 00                	push   $0x0
  8008d0:	ff 75 08             	pushl  0x8(%ebp)
  8008d3:	e8 dc 01 00 00       	call   800ab4 <open>
  8008d8:	89 c3                	mov    %eax,%ebx
  8008da:	83 c4 10             	add    $0x10,%esp
  8008dd:	85 c0                	test   %eax,%eax
  8008df:	78 1b                	js     8008fc <stat+0x36>
		return fd;
	r = fstat(fd, stat);
  8008e1:	83 ec 08             	sub    $0x8,%esp
  8008e4:	ff 75 0c             	pushl  0xc(%ebp)
  8008e7:	50                   	push   %eax
  8008e8:	e8 5b ff ff ff       	call   800848 <fstat>
  8008ed:	89 c6                	mov    %eax,%esi
	close(fd);
  8008ef:	89 1c 24             	mov    %ebx,(%esp)
  8008f2:	e8 fd fb ff ff       	call   8004f4 <close>
	return r;
  8008f7:	83 c4 10             	add    $0x10,%esp
  8008fa:	89 f0                	mov    %esi,%eax
}
  8008fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
  8008ff:	5b                   	pop    %ebx
  800900:	5e                   	pop    %esi
  800901:	5d                   	pop    %ebp
  800902:	c3                   	ret    

00800903 <fsipc>:
// type: request code, passed as the simple integer IPC value.
// dstva: virtual address at which to receive reply page, 0 if none.
// Returns result from the file server.
static int
fsipc(unsigned type, void *dstva)
{
  800903:	55                   	push   %ebp
  800904:	89 e5                	mov    %esp,%ebp
  800906:	56                   	push   %esi
  800907:	53                   	push   %ebx
  800908:	89 c6                	mov    %eax,%esi
  80090a:	89 d3                	mov    %edx,%ebx
	static envid_t fsenv;
	if (fsenv == 0)
  80090c:	83 3d 00 40 80 00 00 	cmpl   $0x0,0x804000
  800913:	75 12                	jne    800927 <fsipc+0x24>
		fsenv = ipc_find_env(ENV_TYPE_FS);
  800915:	83 ec 0c             	sub    $0xc,%esp
  800918:	6a 01                	push   $0x1
  80091a:	e8 a7 11 00 00       	call   801ac6 <ipc_find_env>
  80091f:	a3 00 40 80 00       	mov    %eax,0x804000
  800924:	83 c4 10             	add    $0x10,%esp

	if (debug)
		cprintf("[%08x] fsipc %d %08x\n", thisenv->env_id, type, *(uint32_t *)&fsipcbuf);
	//cprintf("lib/file.c/fsipc(): before ipc_send().\n");
	
	ipc_send(fsenv, type, &fsipcbuf, PTE_P | PTE_W | PTE_U);
  800927:	6a 07                	push   $0x7
  800929:	68 00 50 80 00       	push   $0x805000
  80092e:	56                   	push   %esi
  80092f:	ff 35 00 40 80 00    	pushl  0x804000
  800935:	e8 49 11 00 00       	call   801a83 <ipc_send>

	//cprintf("lib/file.c/fsipc(): ipc_send() done.\n");
	return ipc_recv(NULL, dstva, NULL);
  80093a:	83 c4 0c             	add    $0xc,%esp
  80093d:	6a 00                	push   $0x0
  80093f:	53                   	push   %ebx
  800940:	6a 00                	push   $0x0
  800942:	e8 df 10 00 00       	call   801a26 <ipc_recv>
}
  800947:	8d 65 f8             	lea    -0x8(%ebp),%esp
  80094a:	5b                   	pop    %ebx
  80094b:	5e                   	pop    %esi
  80094c:	5d                   	pop    %ebp
  80094d:	c3                   	ret    

0080094e <devfile_trunc>:
}

// Truncate or extend an open file to 'size' bytes
static int
devfile_trunc(struct Fd *fd, off_t newsize)
{
  80094e:	55                   	push   %ebp
  80094f:	89 e5                	mov    %esp,%ebp
  800951:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.set_size.req_fileid = fd->fd_file.id;
  800954:	8b 45 08             	mov    0x8(%ebp),%eax
  800957:	8b 40 0c             	mov    0xc(%eax),%eax
  80095a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.set_size.req_size = newsize;
  80095f:	8b 45 0c             	mov    0xc(%ebp),%eax
  800962:	a3 04 50 80 00       	mov    %eax,0x805004
	return fsipc(FSREQ_SET_SIZE, NULL);
  800967:	ba 00 00 00 00       	mov    $0x0,%edx
  80096c:	b8 02 00 00 00       	mov    $0x2,%eax
  800971:	e8 8d ff ff ff       	call   800903 <fsipc>
}
  800976:	c9                   	leave  
  800977:	c3                   	ret    

00800978 <devfile_flush>:
// open, unmapping it is enough to free up server-side resources.
// Other than that, we just have to make sure our changes are flushed
// to disk.
static int
devfile_flush(struct Fd *fd)
{
  800978:	55                   	push   %ebp
  800979:	89 e5                	mov    %esp,%ebp
  80097b:	83 ec 08             	sub    $0x8,%esp
	fsipcbuf.flush.req_fileid = fd->fd_file.id;
  80097e:	8b 45 08             	mov    0x8(%ebp),%eax
  800981:	8b 40 0c             	mov    0xc(%eax),%eax
  800984:	a3 00 50 80 00       	mov    %eax,0x805000
	return fsipc(FSREQ_FLUSH, NULL);
  800989:	ba 00 00 00 00       	mov    $0x0,%edx
  80098e:	b8 06 00 00 00       	mov    $0x6,%eax
  800993:	e8 6b ff ff ff       	call   800903 <fsipc>
}
  800998:	c9                   	leave  
  800999:	c3                   	ret    

0080099a <devfile_stat>:
	//panic("devfile_write not implemented");
}

static int
devfile_stat(struct Fd *fd, struct Stat *st)
{
  80099a:	55                   	push   %ebp
  80099b:	89 e5                	mov    %esp,%ebp
  80099d:	53                   	push   %ebx
  80099e:	83 ec 04             	sub    $0x4,%esp
  8009a1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	int r;

	fsipcbuf.stat.req_fileid = fd->fd_file.id;
  8009a4:	8b 45 08             	mov    0x8(%ebp),%eax
  8009a7:	8b 40 0c             	mov    0xc(%eax),%eax
  8009aa:	a3 00 50 80 00       	mov    %eax,0x805000
	if ((r = fsipc(FSREQ_STAT, NULL)) < 0)
  8009af:	ba 00 00 00 00       	mov    $0x0,%edx
  8009b4:	b8 05 00 00 00       	mov    $0x5,%eax
  8009b9:	e8 45 ff ff ff       	call   800903 <fsipc>
  8009be:	85 c0                	test   %eax,%eax
  8009c0:	78 2c                	js     8009ee <devfile_stat+0x54>
		return r;
	strcpy(st->st_name, fsipcbuf.statRet.ret_name);
  8009c2:	83 ec 08             	sub    $0x8,%esp
  8009c5:	68 00 50 80 00       	push   $0x805000
  8009ca:	53                   	push   %ebx
  8009cb:	e8 0f 0d 00 00       	call   8016df <strcpy>
	st->st_size = fsipcbuf.statRet.ret_size;
  8009d0:	a1 80 50 80 00       	mov    0x805080,%eax
  8009d5:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	st->st_isdir = fsipcbuf.statRet.ret_isdir;
  8009db:	a1 84 50 80 00       	mov    0x805084,%eax
  8009e0:	89 83 84 00 00 00    	mov    %eax,0x84(%ebx)
	return 0;
  8009e6:	83 c4 10             	add    $0x10,%esp
  8009e9:	b8 00 00 00 00       	mov    $0x0,%eax
}
  8009ee:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8009f1:	c9                   	leave  
  8009f2:	c3                   	ret    

008009f3 <devfile_write>:
// Returns:
//	 The number of bytes successfully written.
//	 < 0 on error.
static ssize_t
devfile_write(struct Fd *fd, const void *buf, size_t n)
{
  8009f3:	55                   	push   %ebp
  8009f4:	89 e5                	mov    %esp,%ebp
  8009f6:	83 ec 0c             	sub    $0xc,%esp
  8009f9:	8b 45 10             	mov    0x10(%ebp),%eax
	// careful: fsipcbuf.write.req_buf is only so large, but
	// remember that write is always allowed to write *fewer*
	// bytes than requested.
	// LAB 5: Your code here
	int r;
	fsipcbuf.write.req_fileid = fd->fd_file.id;
  8009fc:	8b 55 08             	mov    0x8(%ebp),%edx
  8009ff:	8b 52 0c             	mov    0xc(%edx),%edx
  800a02:	89 15 00 50 80 00    	mov    %edx,0x805000
	fsipcbuf.write.req_n = n;
  800a08:	a3 04 50 80 00       	mov    %eax,0x805004
	memmove(fsipcbuf.write.req_buf, buf, n);
  800a0d:	50                   	push   %eax
  800a0e:	ff 75 0c             	pushl  0xc(%ebp)
  800a11:	68 08 50 80 00       	push   $0x805008
  800a16:	e8 56 0e 00 00       	call   801871 <memmove>
	return fsipc(FSREQ_WRITE, NULL);
  800a1b:	ba 00 00 00 00       	mov    $0x0,%edx
  800a20:	b8 04 00 00 00       	mov    $0x4,%eax
  800a25:	e8 d9 fe ff ff       	call   800903 <fsipc>
	//panic("devfile_write not implemented");
}
  800a2a:	c9                   	leave  
  800a2b:	c3                   	ret    

00800a2c <devfile_read>:
// Returns:
// 	The number of bytes successfully read.
// 	< 0 on error.
static ssize_t
devfile_read(struct Fd *fd, void *buf, size_t n)
{
  800a2c:	55                   	push   %ebp
  800a2d:	89 e5                	mov    %esp,%ebp
  800a2f:	56                   	push   %esi
  800a30:	53                   	push   %ebx
  800a31:	8b 75 10             	mov    0x10(%ebp),%esi
	// filling fsipcbuf.read with the request arguments.  The
	// bytes read will be written back to fsipcbuf by the file
	// system server.
	int r;

	fsipcbuf.read.req_fileid = fd->fd_file.id;
  800a34:	8b 45 08             	mov    0x8(%ebp),%eax
  800a37:	8b 40 0c             	mov    0xc(%eax),%eax
  800a3a:	a3 00 50 80 00       	mov    %eax,0x805000
	fsipcbuf.read.req_n = n;
  800a3f:	89 35 04 50 80 00    	mov    %esi,0x805004
	if ((r = fsipc(FSREQ_READ, NULL)) < 0)
  800a45:	ba 00 00 00 00       	mov    $0x0,%edx
  800a4a:	b8 03 00 00 00       	mov    $0x3,%eax
  800a4f:	e8 af fe ff ff       	call   800903 <fsipc>
  800a54:	89 c3                	mov    %eax,%ebx
  800a56:	85 c0                	test   %eax,%eax
  800a58:	78 51                	js     800aab <devfile_read+0x7f>
		return r;
	assert(r <= n);
  800a5a:	39 c6                	cmp    %eax,%esi
  800a5c:	73 19                	jae    800a77 <devfile_read+0x4b>
  800a5e:	68 a4 1e 80 00       	push   $0x801ea4
  800a63:	68 ab 1e 80 00       	push   $0x801eab
  800a68:	68 80 00 00 00       	push   $0x80
  800a6d:	68 c0 1e 80 00       	push   $0x801ec0
  800a72:	e8 c0 05 00 00       	call   801037 <_panic>
	assert(r <= PGSIZE);
  800a77:	3d 00 10 00 00       	cmp    $0x1000,%eax
  800a7c:	7e 19                	jle    800a97 <devfile_read+0x6b>
  800a7e:	68 cb 1e 80 00       	push   $0x801ecb
  800a83:	68 ab 1e 80 00       	push   $0x801eab
  800a88:	68 81 00 00 00       	push   $0x81
  800a8d:	68 c0 1e 80 00       	push   $0x801ec0
  800a92:	e8 a0 05 00 00       	call   801037 <_panic>
	memmove(buf, fsipcbuf.readRet.ret_buf, r);
  800a97:	83 ec 04             	sub    $0x4,%esp
  800a9a:	50                   	push   %eax
  800a9b:	68 00 50 80 00       	push   $0x805000
  800aa0:	ff 75 0c             	pushl  0xc(%ebp)
  800aa3:	e8 c9 0d 00 00       	call   801871 <memmove>
	return r;
  800aa8:	83 c4 10             	add    $0x10,%esp
}
  800aab:	89 d8                	mov    %ebx,%eax
  800aad:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ab0:	5b                   	pop    %ebx
  800ab1:	5e                   	pop    %esi
  800ab2:	5d                   	pop    %ebp
  800ab3:	c3                   	ret    

00800ab4 <open>:
// 	The file descriptor index on success
// 	-E_BAD_PATH if the path is too long (>= MAXPATHLEN)
// 	< 0 for other errors.
int
open(const char *path, int mode)
{
  800ab4:	55                   	push   %ebp
  800ab5:	89 e5                	mov    %esp,%ebp
  800ab7:	53                   	push   %ebx
  800ab8:	83 ec 20             	sub    $0x20,%esp
  800abb:	8b 5d 08             	mov    0x8(%ebp),%ebx
	// file descriptor.

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
  800abe:	53                   	push   %ebx
  800abf:	e8 e2 0b 00 00       	call   8016a6 <strlen>
  800ac4:	83 c4 10             	add    $0x10,%esp
  800ac7:	3d ff 03 00 00       	cmp    $0x3ff,%eax
  800acc:	7f 67                	jg     800b35 <open+0x81>
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800ace:	83 ec 0c             	sub    $0xc,%esp
  800ad1:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800ad4:	50                   	push   %eax
  800ad5:	e8 a1 f8 ff ff       	call   80037b <fd_alloc>
  800ada:	83 c4 10             	add    $0x10,%esp
		return r;
  800add:	89 c2                	mov    %eax,%edx
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;

	if ((r = fd_alloc(&fd)) < 0)
  800adf:	85 c0                	test   %eax,%eax
  800ae1:	78 57                	js     800b3a <open+0x86>
		return r;

	strcpy(fsipcbuf.open.req_path, path);
  800ae3:	83 ec 08             	sub    $0x8,%esp
  800ae6:	53                   	push   %ebx
  800ae7:	68 00 50 80 00       	push   $0x805000
  800aec:	e8 ee 0b 00 00       	call   8016df <strcpy>
	fsipcbuf.open.req_omode = mode;
  800af1:	8b 45 0c             	mov    0xc(%ebp),%eax
  800af4:	a3 00 54 80 00       	mov    %eax,0x805400
//cprintf("lib/file.c/open(): ready to use fsipc().\n");
	if ((r = fsipc(FSREQ_OPEN, fd)) < 0) {
  800af9:	8b 55 f4             	mov    -0xc(%ebp),%edx
  800afc:	b8 01 00 00 00       	mov    $0x1,%eax
  800b01:	e8 fd fd ff ff       	call   800903 <fsipc>
  800b06:	89 c3                	mov    %eax,%ebx
  800b08:	83 c4 10             	add    $0x10,%esp
  800b0b:	85 c0                	test   %eax,%eax
  800b0d:	79 14                	jns    800b23 <open+0x6f>
		
		fd_close(fd, 0);
  800b0f:	83 ec 08             	sub    $0x8,%esp
  800b12:	6a 00                	push   $0x0
  800b14:	ff 75 f4             	pushl  -0xc(%ebp)
  800b17:	e8 57 f9 ff ff       	call   800473 <fd_close>
		return r;
  800b1c:	83 c4 10             	add    $0x10,%esp
  800b1f:	89 da                	mov    %ebx,%edx
  800b21:	eb 17                	jmp    800b3a <open+0x86>
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
  800b23:	83 ec 0c             	sub    $0xc,%esp
  800b26:	ff 75 f4             	pushl  -0xc(%ebp)
  800b29:	e8 26 f8 ff ff       	call   800354 <fd2num>
  800b2e:	89 c2                	mov    %eax,%edx
  800b30:	83 c4 10             	add    $0x10,%esp
  800b33:	eb 05                	jmp    800b3a <open+0x86>

	int r;
	struct Fd *fd;

	if (strlen(path) >= MAXPATHLEN)
		return -E_BAD_PATH;
  800b35:	ba f4 ff ff ff       	mov    $0xfffffff4,%edx
		fd_close(fd, 0);
		return r;
	}
//cprintf("lib/file.c/open():after to user fsipc().\n");
	return fd2num(fd);
}
  800b3a:	89 d0                	mov    %edx,%eax
  800b3c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800b3f:	c9                   	leave  
  800b40:	c3                   	ret    

00800b41 <sync>:


// Synchronize disk with buffer cache
int
sync(void)
{
  800b41:	55                   	push   %ebp
  800b42:	89 e5                	mov    %esp,%ebp
  800b44:	83 ec 08             	sub    $0x8,%esp
	// Ask the file server to update the disk
	// by writing any dirty blocks in the buffer cache.

	return fsipc(FSREQ_SYNC, NULL);
  800b47:	ba 00 00 00 00       	mov    $0x0,%edx
  800b4c:	b8 08 00 00 00       	mov    $0x8,%eax
  800b51:	e8 ad fd ff ff       	call   800903 <fsipc>
}
  800b56:	c9                   	leave  
  800b57:	c3                   	ret    

00800b58 <devpipe_stat>:
	return i;
}

static int
devpipe_stat(struct Fd *fd, struct Stat *stat)
{
  800b58:	55                   	push   %ebp
  800b59:	89 e5                	mov    %esp,%ebp
  800b5b:	56                   	push   %esi
  800b5c:	53                   	push   %ebx
  800b5d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	struct Pipe *p = (struct Pipe*) fd2data(fd);
  800b60:	83 ec 0c             	sub    $0xc,%esp
  800b63:	ff 75 08             	pushl  0x8(%ebp)
  800b66:	e8 f9 f7 ff ff       	call   800364 <fd2data>
  800b6b:	89 c6                	mov    %eax,%esi
	strcpy(stat->st_name, "<pipe>");
  800b6d:	83 c4 08             	add    $0x8,%esp
  800b70:	68 d7 1e 80 00       	push   $0x801ed7
  800b75:	53                   	push   %ebx
  800b76:	e8 64 0b 00 00       	call   8016df <strcpy>
	stat->st_size = p->p_wpos - p->p_rpos;
  800b7b:	8b 46 04             	mov    0x4(%esi),%eax
  800b7e:	2b 06                	sub    (%esi),%eax
  800b80:	89 83 80 00 00 00    	mov    %eax,0x80(%ebx)
	stat->st_isdir = 0;
  800b86:	c7 83 84 00 00 00 00 	movl   $0x0,0x84(%ebx)
  800b8d:	00 00 00 
	stat->st_dev = &devpipe;
  800b90:	c7 83 88 00 00 00 20 	movl   $0x803020,0x88(%ebx)
  800b97:	30 80 00 
	return 0;
}
  800b9a:	b8 00 00 00 00       	mov    $0x0,%eax
  800b9f:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800ba2:	5b                   	pop    %ebx
  800ba3:	5e                   	pop    %esi
  800ba4:	5d                   	pop    %ebp
  800ba5:	c3                   	ret    

00800ba6 <devpipe_close>:

static int
devpipe_close(struct Fd *fd)
{
  800ba6:	55                   	push   %ebp
  800ba7:	89 e5                	mov    %esp,%ebp
  800ba9:	53                   	push   %ebx
  800baa:	83 ec 0c             	sub    $0xc,%esp
  800bad:	8b 5d 08             	mov    0x8(%ebp),%ebx
	(void) sys_page_unmap(0, fd);
  800bb0:	53                   	push   %ebx
  800bb1:	6a 00                	push   $0x0
  800bb3:	e8 30 f6 ff ff       	call   8001e8 <sys_page_unmap>
	return sys_page_unmap(0, fd2data(fd));
  800bb8:	89 1c 24             	mov    %ebx,(%esp)
  800bbb:	e8 a4 f7 ff ff       	call   800364 <fd2data>
  800bc0:	83 c4 08             	add    $0x8,%esp
  800bc3:	50                   	push   %eax
  800bc4:	6a 00                	push   $0x0
  800bc6:	e8 1d f6 ff ff       	call   8001e8 <sys_page_unmap>
}
  800bcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  800bce:	c9                   	leave  
  800bcf:	c3                   	ret    

00800bd0 <_pipeisclosed>:
	return r;
}

static int
_pipeisclosed(struct Fd *fd, struct Pipe *p)
{
  800bd0:	55                   	push   %ebp
  800bd1:	89 e5                	mov    %esp,%ebp
  800bd3:	57                   	push   %edi
  800bd4:	56                   	push   %esi
  800bd5:	53                   	push   %ebx
  800bd6:	83 ec 1c             	sub    $0x1c,%esp
  800bd9:	89 45 e0             	mov    %eax,-0x20(%ebp)
  800bdc:	89 d7                	mov    %edx,%edi
	int n, nn, ret;

	while (1) {
		n = thisenv->env_runs;
  800bde:	a1 04 40 80 00       	mov    0x804004,%eax
  800be3:	8b 70 58             	mov    0x58(%eax),%esi
		ret = pageref(fd) == pageref(p);
  800be6:	83 ec 0c             	sub    $0xc,%esp
  800be9:	ff 75 e0             	pushl  -0x20(%ebp)
  800bec:	e8 0e 0f 00 00       	call   801aff <pageref>
  800bf1:	89 c3                	mov    %eax,%ebx
  800bf3:	89 3c 24             	mov    %edi,(%esp)
  800bf6:	e8 04 0f 00 00       	call   801aff <pageref>
  800bfb:	83 c4 10             	add    $0x10,%esp
  800bfe:	39 c3                	cmp    %eax,%ebx
  800c00:	0f 94 c1             	sete   %cl
  800c03:	0f b6 c9             	movzbl %cl,%ecx
  800c06:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
		nn = thisenv->env_runs;
  800c09:	8b 15 04 40 80 00    	mov    0x804004,%edx
  800c0f:	8b 4a 58             	mov    0x58(%edx),%ecx
		if (n == nn)
  800c12:	39 ce                	cmp    %ecx,%esi
  800c14:	74 1b                	je     800c31 <_pipeisclosed+0x61>
			return ret;
		if (n != nn && ret == 1)
  800c16:	39 c3                	cmp    %eax,%ebx
  800c18:	75 c4                	jne    800bde <_pipeisclosed+0xe>
			cprintf("pipe race avoided\n", n, thisenv->env_runs, ret);
  800c1a:	8b 42 58             	mov    0x58(%edx),%eax
  800c1d:	ff 75 e4             	pushl  -0x1c(%ebp)
  800c20:	50                   	push   %eax
  800c21:	56                   	push   %esi
  800c22:	68 de 1e 80 00       	push   $0x801ede
  800c27:	e8 e4 04 00 00       	call   801110 <cprintf>
  800c2c:	83 c4 10             	add    $0x10,%esp
  800c2f:	eb ad                	jmp    800bde <_pipeisclosed+0xe>
	}
}
  800c31:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  800c34:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800c37:	5b                   	pop    %ebx
  800c38:	5e                   	pop    %esi
  800c39:	5f                   	pop    %edi
  800c3a:	5d                   	pop    %ebp
  800c3b:	c3                   	ret    

00800c3c <devpipe_write>:
	return i;
}

static ssize_t
devpipe_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800c3c:	55                   	push   %ebp
  800c3d:	89 e5                	mov    %esp,%ebp
  800c3f:	57                   	push   %edi
  800c40:	56                   	push   %esi
  800c41:	53                   	push   %ebx
  800c42:	83 ec 28             	sub    $0x28,%esp
  800c45:	8b 75 08             	mov    0x8(%ebp),%esi
	const uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*) fd2data(fd);
  800c48:	56                   	push   %esi
  800c49:	e8 16 f7 ff ff       	call   800364 <fd2data>
  800c4e:	89 c3                	mov    %eax,%ebx
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800c50:	83 c4 10             	add    $0x10,%esp
  800c53:	bf 00 00 00 00       	mov    $0x0,%edi
  800c58:	eb 4b                	jmp    800ca5 <devpipe_write+0x69>
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
  800c5a:	89 da                	mov    %ebx,%edx
  800c5c:	89 f0                	mov    %esi,%eax
  800c5e:	e8 6d ff ff ff       	call   800bd0 <_pipeisclosed>
  800c63:	85 c0                	test   %eax,%eax
  800c65:	75 48                	jne    800caf <devpipe_write+0x73>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_write yield\n");
			sys_yield();
  800c67:	e8 d8 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_wpos >= p->p_rpos + sizeof(p->p_buf)) {
  800c6c:	8b 43 04             	mov    0x4(%ebx),%eax
  800c6f:	8b 0b                	mov    (%ebx),%ecx
  800c71:	8d 51 20             	lea    0x20(%ecx),%edx
  800c74:	39 d0                	cmp    %edx,%eax
  800c76:	73 e2                	jae    800c5a <devpipe_write+0x1e>
				cprintf("devpipe_write yield\n");
			sys_yield();
		}
		// there's room for a byte.  store it.
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
  800c78:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800c7b:	0f b6 0c 39          	movzbl (%ecx,%edi,1),%ecx
  800c7f:	88 4d e7             	mov    %cl,-0x19(%ebp)
  800c82:	89 c2                	mov    %eax,%edx
  800c84:	c1 fa 1f             	sar    $0x1f,%edx
  800c87:	89 d1                	mov    %edx,%ecx
  800c89:	c1 e9 1b             	shr    $0x1b,%ecx
  800c8c:	8d 14 08             	lea    (%eax,%ecx,1),%edx
  800c8f:	83 e2 1f             	and    $0x1f,%edx
  800c92:	29 ca                	sub    %ecx,%edx
  800c94:	0f b6 4d e7          	movzbl -0x19(%ebp),%ecx
  800c98:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
		p->p_wpos++;
  800c9c:	83 c0 01             	add    $0x1,%eax
  800c9f:	89 43 04             	mov    %eax,0x4(%ebx)
	if (debug)
		cprintf("[%08x] devpipe_write %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800ca2:	83 c7 01             	add    $0x1,%edi
  800ca5:	3b 7d 10             	cmp    0x10(%ebp),%edi
  800ca8:	75 c2                	jne    800c6c <devpipe_write+0x30>
		// wait to increment wpos until the byte is stored!
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
  800caa:	8b 45 10             	mov    0x10(%ebp),%eax
  800cad:	eb 05                	jmp    800cb4 <devpipe_write+0x78>
			// pipe is full
			// if all the readers are gone
			// (it's only writers like us now),
			// note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800caf:	b8 00 00 00 00       	mov    $0x0,%eax
		p->p_buf[p->p_wpos % PIPEBUFSIZ] = buf[i];
		p->p_wpos++;
	}

	return i;
}
  800cb4:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800cb7:	5b                   	pop    %ebx
  800cb8:	5e                   	pop    %esi
  800cb9:	5f                   	pop    %edi
  800cba:	5d                   	pop    %ebp
  800cbb:	c3                   	ret    

00800cbc <devpipe_read>:
	return _pipeisclosed(fd, p);
}

static ssize_t
devpipe_read(struct Fd *fd, void *vbuf, size_t n)
{
  800cbc:	55                   	push   %ebp
  800cbd:	89 e5                	mov    %esp,%ebp
  800cbf:	57                   	push   %edi
  800cc0:	56                   	push   %esi
  800cc1:	53                   	push   %ebx
  800cc2:	83 ec 18             	sub    $0x18,%esp
  800cc5:	8b 7d 08             	mov    0x8(%ebp),%edi
	uint8_t *buf;
	size_t i;
	struct Pipe *p;

	p = (struct Pipe*)fd2data(fd);
  800cc8:	57                   	push   %edi
  800cc9:	e8 96 f6 ff ff       	call   800364 <fd2data>
  800cce:	89 c6                	mov    %eax,%esi
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800cd0:	83 c4 10             	add    $0x10,%esp
  800cd3:	bb 00 00 00 00       	mov    $0x0,%ebx
  800cd8:	eb 3d                	jmp    800d17 <devpipe_read+0x5b>
		while (p->p_rpos == p->p_wpos) {
			// pipe is empty
			// if we got any data, return it
			if (i > 0)
  800cda:	85 db                	test   %ebx,%ebx
  800cdc:	74 04                	je     800ce2 <devpipe_read+0x26>
				return i;
  800cde:	89 d8                	mov    %ebx,%eax
  800ce0:	eb 44                	jmp    800d26 <devpipe_read+0x6a>
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
  800ce2:	89 f2                	mov    %esi,%edx
  800ce4:	89 f8                	mov    %edi,%eax
  800ce6:	e8 e5 fe ff ff       	call   800bd0 <_pipeisclosed>
  800ceb:	85 c0                	test   %eax,%eax
  800ced:	75 32                	jne    800d21 <devpipe_read+0x65>
				return 0;
			// yield and see what happens
			if (debug)
				cprintf("devpipe_read yield\n");
			sys_yield();
  800cef:	e8 50 f4 ff ff       	call   800144 <sys_yield>
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
		while (p->p_rpos == p->p_wpos) {
  800cf4:	8b 06                	mov    (%esi),%eax
  800cf6:	3b 46 04             	cmp    0x4(%esi),%eax
  800cf9:	74 df                	je     800cda <devpipe_read+0x1e>
				cprintf("devpipe_read yield\n");
			sys_yield();
		}
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
  800cfb:	99                   	cltd   
  800cfc:	c1 ea 1b             	shr    $0x1b,%edx
  800cff:	01 d0                	add    %edx,%eax
  800d01:	83 e0 1f             	and    $0x1f,%eax
  800d04:	29 d0                	sub    %edx,%eax
  800d06:	0f b6 44 06 08       	movzbl 0x8(%esi,%eax,1),%eax
  800d0b:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  800d0e:	88 04 19             	mov    %al,(%ecx,%ebx,1)
		p->p_rpos++;
  800d11:	83 06 01             	addl   $0x1,(%esi)
	if (debug)
		cprintf("[%08x] devpipe_read %08x %d rpos %d wpos %d\n",
			thisenv->env_id, uvpt[PGNUM(p)], n, p->p_rpos, p->p_wpos);

	buf = vbuf;
	for (i = 0; i < n; i++) {
  800d14:	83 c3 01             	add    $0x1,%ebx
  800d17:	3b 5d 10             	cmp    0x10(%ebp),%ebx
  800d1a:	75 d8                	jne    800cf4 <devpipe_read+0x38>
		// there's a byte.  take it.
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
  800d1c:	8b 45 10             	mov    0x10(%ebp),%eax
  800d1f:	eb 05                	jmp    800d26 <devpipe_read+0x6a>
			// if we got any data, return it
			if (i > 0)
				return i;
			// if all the writers are gone, note eof
			if (_pipeisclosed(fd, p))
				return 0;
  800d21:	b8 00 00 00 00       	mov    $0x0,%eax
		// wait to increment rpos until the byte is taken!
		buf[i] = p->p_buf[p->p_rpos % PIPEBUFSIZ];
		p->p_rpos++;
	}
	return i;
}
  800d26:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800d29:	5b                   	pop    %ebx
  800d2a:	5e                   	pop    %esi
  800d2b:	5f                   	pop    %edi
  800d2c:	5d                   	pop    %ebp
  800d2d:	c3                   	ret    

00800d2e <pipe>:
	uint8_t p_buf[PIPEBUFSIZ];	// data buffer
};

int
pipe(int pfd[2])
{
  800d2e:	55                   	push   %ebp
  800d2f:	89 e5                	mov    %esp,%ebp
  800d31:	56                   	push   %esi
  800d32:	53                   	push   %ebx
  800d33:	83 ec 1c             	sub    $0x1c,%esp
	int r;
	struct Fd *fd0, *fd1;
	void *va;

	// allocate the file descriptor table entries
	if ((r = fd_alloc(&fd0)) < 0
  800d36:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800d39:	50                   	push   %eax
  800d3a:	e8 3c f6 ff ff       	call   80037b <fd_alloc>
  800d3f:	83 c4 10             	add    $0x10,%esp
  800d42:	89 c2                	mov    %eax,%edx
  800d44:	85 c0                	test   %eax,%eax
  800d46:	0f 88 2c 01 00 00    	js     800e78 <pipe+0x14a>
	    || (r = sys_page_alloc(0, fd0, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d4c:	83 ec 04             	sub    $0x4,%esp
  800d4f:	68 07 04 00 00       	push   $0x407
  800d54:	ff 75 f4             	pushl  -0xc(%ebp)
  800d57:	6a 00                	push   $0x0
  800d59:	e8 05 f4 ff ff       	call   800163 <sys_page_alloc>
  800d5e:	83 c4 10             	add    $0x10,%esp
  800d61:	89 c2                	mov    %eax,%edx
  800d63:	85 c0                	test   %eax,%eax
  800d65:	0f 88 0d 01 00 00    	js     800e78 <pipe+0x14a>
		goto err;

	if ((r = fd_alloc(&fd1)) < 0
  800d6b:	83 ec 0c             	sub    $0xc,%esp
  800d6e:	8d 45 f0             	lea    -0x10(%ebp),%eax
  800d71:	50                   	push   %eax
  800d72:	e8 04 f6 ff ff       	call   80037b <fd_alloc>
  800d77:	89 c3                	mov    %eax,%ebx
  800d79:	83 c4 10             	add    $0x10,%esp
  800d7c:	85 c0                	test   %eax,%eax
  800d7e:	0f 88 e2 00 00 00    	js     800e66 <pipe+0x138>
	    || (r = sys_page_alloc(0, fd1, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800d84:	83 ec 04             	sub    $0x4,%esp
  800d87:	68 07 04 00 00       	push   $0x407
  800d8c:	ff 75 f0             	pushl  -0x10(%ebp)
  800d8f:	6a 00                	push   $0x0
  800d91:	e8 cd f3 ff ff       	call   800163 <sys_page_alloc>
  800d96:	89 c3                	mov    %eax,%ebx
  800d98:	83 c4 10             	add    $0x10,%esp
  800d9b:	85 c0                	test   %eax,%eax
  800d9d:	0f 88 c3 00 00 00    	js     800e66 <pipe+0x138>
		goto err1;

	// allocate the pipe structure as first data page in both
	va = fd2data(fd0);
  800da3:	83 ec 0c             	sub    $0xc,%esp
  800da6:	ff 75 f4             	pushl  -0xc(%ebp)
  800da9:	e8 b6 f5 ff ff       	call   800364 <fd2data>
  800dae:	89 c6                	mov    %eax,%esi
	if ((r = sys_page_alloc(0, va, PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800db0:	83 c4 0c             	add    $0xc,%esp
  800db3:	68 07 04 00 00       	push   $0x407
  800db8:	50                   	push   %eax
  800db9:	6a 00                	push   $0x0
  800dbb:	e8 a3 f3 ff ff       	call   800163 <sys_page_alloc>
  800dc0:	89 c3                	mov    %eax,%ebx
  800dc2:	83 c4 10             	add    $0x10,%esp
  800dc5:	85 c0                	test   %eax,%eax
  800dc7:	0f 88 89 00 00 00    	js     800e56 <pipe+0x128>
		goto err2;
	if ((r = sys_page_map(0, va, 0, fd2data(fd1), PTE_P|PTE_W|PTE_U|PTE_SHARE)) < 0)
  800dcd:	83 ec 0c             	sub    $0xc,%esp
  800dd0:	ff 75 f0             	pushl  -0x10(%ebp)
  800dd3:	e8 8c f5 ff ff       	call   800364 <fd2data>
  800dd8:	c7 04 24 07 04 00 00 	movl   $0x407,(%esp)
  800ddf:	50                   	push   %eax
  800de0:	6a 00                	push   $0x0
  800de2:	56                   	push   %esi
  800de3:	6a 00                	push   $0x0
  800de5:	e8 bc f3 ff ff       	call   8001a6 <sys_page_map>
  800dea:	89 c3                	mov    %eax,%ebx
  800dec:	83 c4 20             	add    $0x20,%esp
  800def:	85 c0                	test   %eax,%eax
  800df1:	78 55                	js     800e48 <pipe+0x11a>
		goto err3;

	// set up fd structures
	fd0->fd_dev_id = devpipe.dev_id;
  800df3:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800df9:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800dfc:	89 10                	mov    %edx,(%eax)
	fd0->fd_omode = O_RDONLY;
  800dfe:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800e01:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)

	fd1->fd_dev_id = devpipe.dev_id;
  800e08:	8b 15 20 30 80 00    	mov    0x803020,%edx
  800e0e:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e11:	89 10                	mov    %edx,(%eax)
	fd1->fd_omode = O_WRONLY;
  800e13:	8b 45 f0             	mov    -0x10(%ebp),%eax
  800e16:	c7 40 08 01 00 00 00 	movl   $0x1,0x8(%eax)

	if (debug)
		cprintf("[%08x] pipecreate %08x\n", thisenv->env_id, uvpt[PGNUM(va)]);

	pfd[0] = fd2num(fd0);
  800e1d:	83 ec 0c             	sub    $0xc,%esp
  800e20:	ff 75 f4             	pushl  -0xc(%ebp)
  800e23:	e8 2c f5 ff ff       	call   800354 <fd2num>
  800e28:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e2b:	89 01                	mov    %eax,(%ecx)
	pfd[1] = fd2num(fd1);
  800e2d:	83 c4 04             	add    $0x4,%esp
  800e30:	ff 75 f0             	pushl  -0x10(%ebp)
  800e33:	e8 1c f5 ff ff       	call   800354 <fd2num>
  800e38:	8b 4d 08             	mov    0x8(%ebp),%ecx
  800e3b:	89 41 04             	mov    %eax,0x4(%ecx)
	return 0;
  800e3e:	83 c4 10             	add    $0x10,%esp
  800e41:	ba 00 00 00 00       	mov    $0x0,%edx
  800e46:	eb 30                	jmp    800e78 <pipe+0x14a>

    err3:
	sys_page_unmap(0, va);
  800e48:	83 ec 08             	sub    $0x8,%esp
  800e4b:	56                   	push   %esi
  800e4c:	6a 00                	push   $0x0
  800e4e:	e8 95 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e53:	83 c4 10             	add    $0x10,%esp
    err2:
	sys_page_unmap(0, fd1);
  800e56:	83 ec 08             	sub    $0x8,%esp
  800e59:	ff 75 f0             	pushl  -0x10(%ebp)
  800e5c:	6a 00                	push   $0x0
  800e5e:	e8 85 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e63:	83 c4 10             	add    $0x10,%esp
    err1:
	sys_page_unmap(0, fd0);
  800e66:	83 ec 08             	sub    $0x8,%esp
  800e69:	ff 75 f4             	pushl  -0xc(%ebp)
  800e6c:	6a 00                	push   $0x0
  800e6e:	e8 75 f3 ff ff       	call   8001e8 <sys_page_unmap>
  800e73:	83 c4 10             	add    $0x10,%esp
  800e76:	89 da                	mov    %ebx,%edx
    err:
	return r;
}
  800e78:	89 d0                	mov    %edx,%eax
  800e7a:	8d 65 f8             	lea    -0x8(%ebp),%esp
  800e7d:	5b                   	pop    %ebx
  800e7e:	5e                   	pop    %esi
  800e7f:	5d                   	pop    %ebp
  800e80:	c3                   	ret    

00800e81 <pipeisclosed>:
	}
}

int
pipeisclosed(int fdnum)
{
  800e81:	55                   	push   %ebp
  800e82:	89 e5                	mov    %esp,%ebp
  800e84:	83 ec 20             	sub    $0x20,%esp
	struct Fd *fd;
	struct Pipe *p;
	int r;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800e87:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800e8a:	50                   	push   %eax
  800e8b:	ff 75 08             	pushl  0x8(%ebp)
  800e8e:	e8 37 f5 ff ff       	call   8003ca <fd_lookup>
  800e93:	83 c4 10             	add    $0x10,%esp
  800e96:	85 c0                	test   %eax,%eax
  800e98:	78 18                	js     800eb2 <pipeisclosed+0x31>
		return r;
	p = (struct Pipe*) fd2data(fd);
  800e9a:	83 ec 0c             	sub    $0xc,%esp
  800e9d:	ff 75 f4             	pushl  -0xc(%ebp)
  800ea0:	e8 bf f4 ff ff       	call   800364 <fd2data>
	return _pipeisclosed(fd, p);
  800ea5:	89 c2                	mov    %eax,%edx
  800ea7:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800eaa:	e8 21 fd ff ff       	call   800bd0 <_pipeisclosed>
  800eaf:	83 c4 10             	add    $0x10,%esp
}
  800eb2:	c9                   	leave  
  800eb3:	c3                   	ret    

00800eb4 <devcons_close>:
	return tot;
}

static int
devcons_close(struct Fd *fd)
{
  800eb4:	55                   	push   %ebp
  800eb5:	89 e5                	mov    %esp,%ebp
	USED(fd);

	return 0;
}
  800eb7:	b8 00 00 00 00       	mov    $0x0,%eax
  800ebc:	5d                   	pop    %ebp
  800ebd:	c3                   	ret    

00800ebe <devcons_stat>:

static int
devcons_stat(struct Fd *fd, struct Stat *stat)
{
  800ebe:	55                   	push   %ebp
  800ebf:	89 e5                	mov    %esp,%ebp
  800ec1:	83 ec 10             	sub    $0x10,%esp
	strcpy(stat->st_name, "<cons>");
  800ec4:	68 f6 1e 80 00       	push   $0x801ef6
  800ec9:	ff 75 0c             	pushl  0xc(%ebp)
  800ecc:	e8 0e 08 00 00       	call   8016df <strcpy>
	return 0;
}
  800ed1:	b8 00 00 00 00       	mov    $0x0,%eax
  800ed6:	c9                   	leave  
  800ed7:	c3                   	ret    

00800ed8 <devcons_write>:
	return 1;
}

static ssize_t
devcons_write(struct Fd *fd, const void *vbuf, size_t n)
{
  800ed8:	55                   	push   %ebp
  800ed9:	89 e5                	mov    %esp,%ebp
  800edb:	57                   	push   %edi
  800edc:	56                   	push   %esi
  800edd:	53                   	push   %ebx
  800ede:	81 ec 8c 00 00 00    	sub    $0x8c,%esp
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800ee4:	be 00 00 00 00       	mov    $0x0,%esi
		m = n - tot;
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800ee9:	8d bd 68 ff ff ff    	lea    -0x98(%ebp),%edi
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800eef:	eb 2d                	jmp    800f1e <devcons_write+0x46>
		m = n - tot;
  800ef1:	8b 5d 10             	mov    0x10(%ebp),%ebx
  800ef4:	29 f3                	sub    %esi,%ebx
		if (m > sizeof(buf) - 1)
  800ef6:	83 fb 7f             	cmp    $0x7f,%ebx
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
		m = n - tot;
  800ef9:	ba 7f 00 00 00       	mov    $0x7f,%edx
  800efe:	0f 47 da             	cmova  %edx,%ebx
		if (m > sizeof(buf) - 1)
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
  800f01:	83 ec 04             	sub    $0x4,%esp
  800f04:	53                   	push   %ebx
  800f05:	03 45 0c             	add    0xc(%ebp),%eax
  800f08:	50                   	push   %eax
  800f09:	57                   	push   %edi
  800f0a:	e8 62 09 00 00       	call   801871 <memmove>
		sys_cputs(buf, m);
  800f0f:	83 c4 08             	add    $0x8,%esp
  800f12:	53                   	push   %ebx
  800f13:	57                   	push   %edi
  800f14:	e8 8e f1 ff ff       	call   8000a7 <sys_cputs>
	int tot, m;
	char buf[128];

	// mistake: have to nul-terminate arg to sys_cputs,
	// so we have to copy vbuf into buf in chunks and nul-terminate.
	for (tot = 0; tot < n; tot += m) {
  800f19:	01 de                	add    %ebx,%esi
  800f1b:	83 c4 10             	add    $0x10,%esp
  800f1e:	89 f0                	mov    %esi,%eax
  800f20:	3b 75 10             	cmp    0x10(%ebp),%esi
  800f23:	72 cc                	jb     800ef1 <devcons_write+0x19>
			m = sizeof(buf) - 1;
		memmove(buf, (char*)vbuf + tot, m);
		sys_cputs(buf, m);
	}
	return tot;
}
  800f25:	8d 65 f4             	lea    -0xc(%ebp),%esp
  800f28:	5b                   	pop    %ebx
  800f29:	5e                   	pop    %esi
  800f2a:	5f                   	pop    %edi
  800f2b:	5d                   	pop    %ebp
  800f2c:	c3                   	ret    

00800f2d <devcons_read>:
	return fd2num(fd);
}

static ssize_t
devcons_read(struct Fd *fd, void *vbuf, size_t n)
{
  800f2d:	55                   	push   %ebp
  800f2e:	89 e5                	mov    %esp,%ebp
  800f30:	83 ec 08             	sub    $0x8,%esp
  800f33:	b8 00 00 00 00       	mov    $0x0,%eax
	int c;

	if (n == 0)
  800f38:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
  800f3c:	74 2a                	je     800f68 <devcons_read+0x3b>
  800f3e:	eb 05                	jmp    800f45 <devcons_read+0x18>
		return 0;

	while ((c = sys_cgetc()) == 0)
		sys_yield();
  800f40:	e8 ff f1 ff ff       	call   800144 <sys_yield>
	int c;

	if (n == 0)
		return 0;

	while ((c = sys_cgetc()) == 0)
  800f45:	e8 7b f1 ff ff       	call   8000c5 <sys_cgetc>
  800f4a:	85 c0                	test   %eax,%eax
  800f4c:	74 f2                	je     800f40 <devcons_read+0x13>
		sys_yield();
	if (c < 0)
  800f4e:	85 c0                	test   %eax,%eax
  800f50:	78 16                	js     800f68 <devcons_read+0x3b>
		return c;
	if (c == 0x04)	// ctl-d is eof
  800f52:	83 f8 04             	cmp    $0x4,%eax
  800f55:	74 0c                	je     800f63 <devcons_read+0x36>
		return 0;
	*(char*)vbuf = c;
  800f57:	8b 55 0c             	mov    0xc(%ebp),%edx
  800f5a:	88 02                	mov    %al,(%edx)
	return 1;
  800f5c:	b8 01 00 00 00       	mov    $0x1,%eax
  800f61:	eb 05                	jmp    800f68 <devcons_read+0x3b>
	while ((c = sys_cgetc()) == 0)
		sys_yield();
	if (c < 0)
		return c;
	if (c == 0x04)	// ctl-d is eof
		return 0;
  800f63:	b8 00 00 00 00       	mov    $0x0,%eax
	*(char*)vbuf = c;
	return 1;
}
  800f68:	c9                   	leave  
  800f69:	c3                   	ret    

00800f6a <cputchar>:
#include <inc/string.h>
#include <inc/lib.h>

void
cputchar(int ch)
{
  800f6a:	55                   	push   %ebp
  800f6b:	89 e5                	mov    %esp,%ebp
  800f6d:	83 ec 20             	sub    $0x20,%esp
	char c = ch;
  800f70:	8b 45 08             	mov    0x8(%ebp),%eax
  800f73:	88 45 f7             	mov    %al,-0x9(%ebp)

	// Unlike standard Unix's putchar,
	// the cputchar function _always_ outputs to the system console.
	sys_cputs(&c, 1);
  800f76:	6a 01                	push   $0x1
  800f78:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f7b:	50                   	push   %eax
  800f7c:	e8 26 f1 ff ff       	call   8000a7 <sys_cputs>
}
  800f81:	83 c4 10             	add    $0x10,%esp
  800f84:	c9                   	leave  
  800f85:	c3                   	ret    

00800f86 <getchar>:

int
getchar(void)
{
  800f86:	55                   	push   %ebp
  800f87:	89 e5                	mov    %esp,%ebp
  800f89:	83 ec 1c             	sub    $0x1c,%esp
	int r;

	// JOS does, however, support standard _input_ redirection,
	// allowing the user to redirect script files to the shell and such.
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
  800f8c:	6a 01                	push   $0x1
  800f8e:	8d 45 f7             	lea    -0x9(%ebp),%eax
  800f91:	50                   	push   %eax
  800f92:	6a 00                	push   $0x0
  800f94:	e8 97 f6 ff ff       	call   800630 <read>
	if (r < 0)
  800f99:	83 c4 10             	add    $0x10,%esp
  800f9c:	85 c0                	test   %eax,%eax
  800f9e:	78 0f                	js     800faf <getchar+0x29>
		return r;
	if (r < 1)
  800fa0:	85 c0                	test   %eax,%eax
  800fa2:	7e 06                	jle    800faa <getchar+0x24>
		return -E_EOF;
	return c;
  800fa4:	0f b6 45 f7          	movzbl -0x9(%ebp),%eax
  800fa8:	eb 05                	jmp    800faf <getchar+0x29>
	// getchar() reads a character from file descriptor 0.
	r = read(0, &c, 1);
	if (r < 0)
		return r;
	if (r < 1)
		return -E_EOF;
  800faa:	b8 f8 ff ff ff       	mov    $0xfffffff8,%eax
	return c;
}
  800faf:	c9                   	leave  
  800fb0:	c3                   	ret    

00800fb1 <iscons>:
	.dev_stat =	devcons_stat
};

int
iscons(int fdnum)
{
  800fb1:	55                   	push   %ebp
  800fb2:	89 e5                	mov    %esp,%ebp
  800fb4:	83 ec 20             	sub    $0x20,%esp
	int r;
	struct Fd *fd;

	if ((r = fd_lookup(fdnum, &fd)) < 0)
  800fb7:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fba:	50                   	push   %eax
  800fbb:	ff 75 08             	pushl  0x8(%ebp)
  800fbe:	e8 07 f4 ff ff       	call   8003ca <fd_lookup>
  800fc3:	83 c4 10             	add    $0x10,%esp
  800fc6:	85 c0                	test   %eax,%eax
  800fc8:	78 11                	js     800fdb <iscons+0x2a>
		return r;
	return fd->fd_dev_id == devcons.dev_id;
  800fca:	8b 45 f4             	mov    -0xc(%ebp),%eax
  800fcd:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  800fd3:	39 10                	cmp    %edx,(%eax)
  800fd5:	0f 94 c0             	sete   %al
  800fd8:	0f b6 c0             	movzbl %al,%eax
}
  800fdb:	c9                   	leave  
  800fdc:	c3                   	ret    

00800fdd <opencons>:

int
opencons(void)
{
  800fdd:	55                   	push   %ebp
  800fde:	89 e5                	mov    %esp,%ebp
  800fe0:	83 ec 24             	sub    $0x24,%esp
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800fe3:	8d 45 f4             	lea    -0xc(%ebp),%eax
  800fe6:	50                   	push   %eax
  800fe7:	e8 8f f3 ff ff       	call   80037b <fd_alloc>
  800fec:	83 c4 10             	add    $0x10,%esp
		return r;
  800fef:	89 c2                	mov    %eax,%edx
opencons(void)
{
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
  800ff1:	85 c0                	test   %eax,%eax
  800ff3:	78 3e                	js     801033 <opencons+0x56>
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  800ff5:	83 ec 04             	sub    $0x4,%esp
  800ff8:	68 07 04 00 00       	push   $0x407
  800ffd:	ff 75 f4             	pushl  -0xc(%ebp)
  801000:	6a 00                	push   $0x0
  801002:	e8 5c f1 ff ff       	call   800163 <sys_page_alloc>
  801007:	83 c4 10             	add    $0x10,%esp
		return r;
  80100a:	89 c2                	mov    %eax,%edx
	int r;
	struct Fd* fd;

	if ((r = fd_alloc(&fd)) < 0)
		return r;
	if ((r = sys_page_alloc(0, fd, PTE_P|PTE_U|PTE_W|PTE_SHARE)) < 0)
  80100c:	85 c0                	test   %eax,%eax
  80100e:	78 23                	js     801033 <opencons+0x56>
		return r;
	fd->fd_dev_id = devcons.dev_id;
  801010:	8b 15 3c 30 80 00    	mov    0x80303c,%edx
  801016:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801019:	89 10                	mov    %edx,(%eax)
	fd->fd_omode = O_RDWR;
  80101b:	8b 45 f4             	mov    -0xc(%ebp),%eax
  80101e:	c7 40 08 02 00 00 00 	movl   $0x2,0x8(%eax)
	return fd2num(fd);
  801025:	83 ec 0c             	sub    $0xc,%esp
  801028:	50                   	push   %eax
  801029:	e8 26 f3 ff ff       	call   800354 <fd2num>
  80102e:	89 c2                	mov    %eax,%edx
  801030:	83 c4 10             	add    $0x10,%esp
}
  801033:	89 d0                	mov    %edx,%eax
  801035:	c9                   	leave  
  801036:	c3                   	ret    

00801037 <_panic>:
 * It prints "panic: <message>", then causes a breakpoint exception,
 * which causes JOS to enter the JOS kernel monitor.
 */
void
_panic(const char *file, int line, const char *fmt, ...)
{
  801037:	55                   	push   %ebp
  801038:	89 e5                	mov    %esp,%ebp
  80103a:	56                   	push   %esi
  80103b:	53                   	push   %ebx
	va_list ap;

	va_start(ap, fmt);
  80103c:	8d 5d 14             	lea    0x14(%ebp),%ebx

	// Print the panic message
	cprintf("[%08x] user panic in %s at %s:%d: ",
  80103f:	8b 35 00 30 80 00    	mov    0x803000,%esi
  801045:	e8 db f0 ff ff       	call   800125 <sys_getenvid>
  80104a:	83 ec 0c             	sub    $0xc,%esp
  80104d:	ff 75 0c             	pushl  0xc(%ebp)
  801050:	ff 75 08             	pushl  0x8(%ebp)
  801053:	56                   	push   %esi
  801054:	50                   	push   %eax
  801055:	68 04 1f 80 00       	push   $0x801f04
  80105a:	e8 b1 00 00 00       	call   801110 <cprintf>
		sys_getenvid(), binaryname, file, line);
	vcprintf(fmt, ap);
  80105f:	83 c4 18             	add    $0x18,%esp
  801062:	53                   	push   %ebx
  801063:	ff 75 10             	pushl  0x10(%ebp)
  801066:	e8 54 00 00 00       	call   8010bf <vcprintf>
	cprintf("\n");
  80106b:	c7 04 24 ef 1e 80 00 	movl   $0x801eef,(%esp)
  801072:	e8 99 00 00 00       	call   801110 <cprintf>
  801077:	83 c4 10             	add    $0x10,%esp

	// Cause a breakpoint exception
	while (1)
		asm volatile("int3");
  80107a:	cc                   	int3   
  80107b:	eb fd                	jmp    80107a <_panic+0x43>

0080107d <putch>:
};


static void
putch(int ch, struct printbuf *b)
{
  80107d:	55                   	push   %ebp
  80107e:	89 e5                	mov    %esp,%ebp
  801080:	53                   	push   %ebx
  801081:	83 ec 04             	sub    $0x4,%esp
  801084:	8b 5d 0c             	mov    0xc(%ebp),%ebx
	b->buf[b->idx++] = ch;
  801087:	8b 13                	mov    (%ebx),%edx
  801089:	8d 42 01             	lea    0x1(%edx),%eax
  80108c:	89 03                	mov    %eax,(%ebx)
  80108e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801091:	88 4c 13 08          	mov    %cl,0x8(%ebx,%edx,1)
	if (b->idx == 256-1) {
  801095:	3d ff 00 00 00       	cmp    $0xff,%eax
  80109a:	75 1a                	jne    8010b6 <putch+0x39>
		sys_cputs(b->buf, b->idx);
  80109c:	83 ec 08             	sub    $0x8,%esp
  80109f:	68 ff 00 00 00       	push   $0xff
  8010a4:	8d 43 08             	lea    0x8(%ebx),%eax
  8010a7:	50                   	push   %eax
  8010a8:	e8 fa ef ff ff       	call   8000a7 <sys_cputs>
		b->idx = 0;
  8010ad:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  8010b3:	83 c4 10             	add    $0x10,%esp
	}
	b->cnt++;
  8010b6:	83 43 04 01          	addl   $0x1,0x4(%ebx)
}
  8010ba:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  8010bd:	c9                   	leave  
  8010be:	c3                   	ret    

008010bf <vcprintf>:

int
vcprintf(const char *fmt, va_list ap)
{
  8010bf:	55                   	push   %ebp
  8010c0:	89 e5                	mov    %esp,%ebp
  8010c2:	81 ec 18 01 00 00    	sub    $0x118,%esp
	struct printbuf b;

	
	b.idx = 0;
  8010c8:	c7 85 f0 fe ff ff 00 	movl   $0x0,-0x110(%ebp)
  8010cf:	00 00 00 
	b.cnt = 0;
  8010d2:	c7 85 f4 fe ff ff 00 	movl   $0x0,-0x10c(%ebp)
  8010d9:	00 00 00 
	vprintfmt((void*)putch, &b, fmt, ap);
  8010dc:	ff 75 0c             	pushl  0xc(%ebp)
  8010df:	ff 75 08             	pushl  0x8(%ebp)
  8010e2:	8d 85 f0 fe ff ff    	lea    -0x110(%ebp),%eax
  8010e8:	50                   	push   %eax
  8010e9:	68 7d 10 80 00       	push   $0x80107d
  8010ee:	e8 54 01 00 00       	call   801247 <vprintfmt>
	sys_cputs(b.buf, b.idx);
  8010f3:	83 c4 08             	add    $0x8,%esp
  8010f6:	ff b5 f0 fe ff ff    	pushl  -0x110(%ebp)
  8010fc:	8d 85 f8 fe ff ff    	lea    -0x108(%ebp),%eax
  801102:	50                   	push   %eax
  801103:	e8 9f ef ff ff       	call   8000a7 <sys_cputs>

	return b.cnt;
}
  801108:	8b 85 f4 fe ff ff    	mov    -0x10c(%ebp),%eax
  80110e:	c9                   	leave  
  80110f:	c3                   	ret    

00801110 <cprintf>:

int
cprintf(const char *fmt, ...)
{
  801110:	55                   	push   %ebp
  801111:	89 e5                	mov    %esp,%ebp
  801113:	83 ec 10             	sub    $0x10,%esp
	va_list ap;
	int cnt;

	va_start(ap, fmt);
  801116:	8d 45 0c             	lea    0xc(%ebp),%eax
	cnt = vcprintf(fmt, ap);
  801119:	50                   	push   %eax
  80111a:	ff 75 08             	pushl  0x8(%ebp)
  80111d:	e8 9d ff ff ff       	call   8010bf <vcprintf>
	va_end(ap);

	return cnt;
}
  801122:	c9                   	leave  
  801123:	c3                   	ret    

00801124 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
  801124:	55                   	push   %ebp
  801125:	89 e5                	mov    %esp,%ebp
  801127:	57                   	push   %edi
  801128:	56                   	push   %esi
  801129:	53                   	push   %ebx
  80112a:	83 ec 1c             	sub    $0x1c,%esp
  80112d:	89 c7                	mov    %eax,%edi
  80112f:	89 d6                	mov    %edx,%esi
  801131:	8b 45 08             	mov    0x8(%ebp),%eax
  801134:	8b 55 0c             	mov    0xc(%ebp),%edx
  801137:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80113a:	89 55 dc             	mov    %edx,-0x24(%ebp)
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
  80113d:	8b 4d 10             	mov    0x10(%ebp),%ecx
  801140:	bb 00 00 00 00       	mov    $0x0,%ebx
  801145:	89 4d e0             	mov    %ecx,-0x20(%ebp)
  801148:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  80114b:	39 d3                	cmp    %edx,%ebx
  80114d:	72 05                	jb     801154 <printnum+0x30>
  80114f:	39 45 10             	cmp    %eax,0x10(%ebp)
  801152:	77 45                	ja     801199 <printnum+0x75>
		printnum(putch, putdat, num / base, base, width - 1, padc);
  801154:	83 ec 0c             	sub    $0xc,%esp
  801157:	ff 75 18             	pushl  0x18(%ebp)
  80115a:	8b 45 14             	mov    0x14(%ebp),%eax
  80115d:	8d 58 ff             	lea    -0x1(%eax),%ebx
  801160:	53                   	push   %ebx
  801161:	ff 75 10             	pushl  0x10(%ebp)
  801164:	83 ec 08             	sub    $0x8,%esp
  801167:	ff 75 e4             	pushl  -0x1c(%ebp)
  80116a:	ff 75 e0             	pushl  -0x20(%ebp)
  80116d:	ff 75 dc             	pushl  -0x24(%ebp)
  801170:	ff 75 d8             	pushl  -0x28(%ebp)
  801173:	e8 c8 09 00 00       	call   801b40 <__udivdi3>
  801178:	83 c4 18             	add    $0x18,%esp
  80117b:	52                   	push   %edx
  80117c:	50                   	push   %eax
  80117d:	89 f2                	mov    %esi,%edx
  80117f:	89 f8                	mov    %edi,%eax
  801181:	e8 9e ff ff ff       	call   801124 <printnum>
  801186:	83 c4 20             	add    $0x20,%esp
  801189:	eb 18                	jmp    8011a3 <printnum+0x7f>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
  80118b:	83 ec 08             	sub    $0x8,%esp
  80118e:	56                   	push   %esi
  80118f:	ff 75 18             	pushl  0x18(%ebp)
  801192:	ff d7                	call   *%edi
  801194:	83 c4 10             	add    $0x10,%esp
  801197:	eb 03                	jmp    80119c <printnum+0x78>
  801199:	8b 5d 14             	mov    0x14(%ebp),%ebx
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
  80119c:	83 eb 01             	sub    $0x1,%ebx
  80119f:	85 db                	test   %ebx,%ebx
  8011a1:	7f e8                	jg     80118b <printnum+0x67>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
  8011a3:	83 ec 08             	sub    $0x8,%esp
  8011a6:	56                   	push   %esi
  8011a7:	83 ec 04             	sub    $0x4,%esp
  8011aa:	ff 75 e4             	pushl  -0x1c(%ebp)
  8011ad:	ff 75 e0             	pushl  -0x20(%ebp)
  8011b0:	ff 75 dc             	pushl  -0x24(%ebp)
  8011b3:	ff 75 d8             	pushl  -0x28(%ebp)
  8011b6:	e8 b5 0a 00 00       	call   801c70 <__umoddi3>
  8011bb:	83 c4 14             	add    $0x14,%esp
  8011be:	0f be 80 27 1f 80 00 	movsbl 0x801f27(%eax),%eax
  8011c5:	50                   	push   %eax
  8011c6:	ff d7                	call   *%edi
}
  8011c8:	83 c4 10             	add    $0x10,%esp
  8011cb:	8d 65 f4             	lea    -0xc(%ebp),%esp
  8011ce:	5b                   	pop    %ebx
  8011cf:	5e                   	pop    %esi
  8011d0:	5f                   	pop    %edi
  8011d1:	5d                   	pop    %ebp
  8011d2:	c3                   	ret    

008011d3 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
  8011d3:	55                   	push   %ebp
  8011d4:	89 e5                	mov    %esp,%ebp
	if (lflag >= 2)
  8011d6:	83 fa 01             	cmp    $0x1,%edx
  8011d9:	7e 0e                	jle    8011e9 <getuint+0x16>
		return va_arg(*ap, unsigned long long);
  8011db:	8b 10                	mov    (%eax),%edx
  8011dd:	8d 4a 08             	lea    0x8(%edx),%ecx
  8011e0:	89 08                	mov    %ecx,(%eax)
  8011e2:	8b 02                	mov    (%edx),%eax
  8011e4:	8b 52 04             	mov    0x4(%edx),%edx
  8011e7:	eb 22                	jmp    80120b <getuint+0x38>
	else if (lflag)
  8011e9:	85 d2                	test   %edx,%edx
  8011eb:	74 10                	je     8011fd <getuint+0x2a>
		return va_arg(*ap, unsigned long);
  8011ed:	8b 10                	mov    (%eax),%edx
  8011ef:	8d 4a 04             	lea    0x4(%edx),%ecx
  8011f2:	89 08                	mov    %ecx,(%eax)
  8011f4:	8b 02                	mov    (%edx),%eax
  8011f6:	ba 00 00 00 00       	mov    $0x0,%edx
  8011fb:	eb 0e                	jmp    80120b <getuint+0x38>
	else
		return va_arg(*ap, unsigned int);
  8011fd:	8b 10                	mov    (%eax),%edx
  8011ff:	8d 4a 04             	lea    0x4(%edx),%ecx
  801202:	89 08                	mov    %ecx,(%eax)
  801204:	8b 02                	mov    (%edx),%eax
  801206:	ba 00 00 00 00       	mov    $0x0,%edx
}
  80120b:	5d                   	pop    %ebp
  80120c:	c3                   	ret    

0080120d <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
  80120d:	55                   	push   %ebp
  80120e:	89 e5                	mov    %esp,%ebp
  801210:	8b 45 0c             	mov    0xc(%ebp),%eax
	b->cnt++;
  801213:	83 40 08 01          	addl   $0x1,0x8(%eax)
	if (b->buf < b->ebuf)
  801217:	8b 10                	mov    (%eax),%edx
  801219:	3b 50 04             	cmp    0x4(%eax),%edx
  80121c:	73 0a                	jae    801228 <sprintputch+0x1b>
		*b->buf++ = ch;
  80121e:	8d 4a 01             	lea    0x1(%edx),%ecx
  801221:	89 08                	mov    %ecx,(%eax)
  801223:	8b 45 08             	mov    0x8(%ebp),%eax
  801226:	88 02                	mov    %al,(%edx)
}
  801228:	5d                   	pop    %ebp
  801229:	c3                   	ret    

0080122a <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
  80122a:	55                   	push   %ebp
  80122b:	89 e5                	mov    %esp,%ebp
  80122d:	83 ec 08             	sub    $0x8,%esp
	va_list ap;

	va_start(ap, fmt);
  801230:	8d 45 14             	lea    0x14(%ebp),%eax
	vprintfmt(putch, putdat, fmt, ap);
  801233:	50                   	push   %eax
  801234:	ff 75 10             	pushl  0x10(%ebp)
  801237:	ff 75 0c             	pushl  0xc(%ebp)
  80123a:	ff 75 08             	pushl  0x8(%ebp)
  80123d:	e8 05 00 00 00       	call   801247 <vprintfmt>
	va_end(ap);
}
  801242:	83 c4 10             	add    $0x10,%esp
  801245:	c9                   	leave  
  801246:	c3                   	ret    

00801247 <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
  801247:	55                   	push   %ebp
  801248:	89 e5                	mov    %esp,%ebp
  80124a:	57                   	push   %edi
  80124b:	56                   	push   %esi
  80124c:	53                   	push   %ebx
  80124d:	83 ec 2c             	sub    $0x2c,%esp
  801250:	8b 75 08             	mov    0x8(%ebp),%esi
  801253:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  801256:	8b 7d 10             	mov    0x10(%ebp),%edi
  801259:	eb 12                	jmp    80126d <vprintfmt+0x26>
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
			if (ch == '\0')
  80125b:	85 c0                	test   %eax,%eax
  80125d:	0f 84 d3 03 00 00    	je     801636 <vprintfmt+0x3ef>
				return;
			putch(ch, putdat);
  801263:	83 ec 08             	sub    $0x8,%esp
  801266:	53                   	push   %ebx
  801267:	50                   	push   %eax
  801268:	ff d6                	call   *%esi
  80126a:	83 c4 10             	add    $0x10,%esp
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
  80126d:	83 c7 01             	add    $0x1,%edi
  801270:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  801274:	83 f8 25             	cmp    $0x25,%eax
  801277:	75 e2                	jne    80125b <vprintfmt+0x14>
  801279:	c6 45 d4 20          	movb   $0x20,-0x2c(%ebp)
  80127d:	c7 45 d8 00 00 00 00 	movl   $0x0,-0x28(%ebp)
  801284:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80128b:	c7 45 e0 ff ff ff ff 	movl   $0xffffffff,-0x20(%ebp)
  801292:	ba 00 00 00 00       	mov    $0x0,%edx
  801297:	eb 07                	jmp    8012a0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801299:	8b 7d e4             	mov    -0x1c(%ebp),%edi

		// flag to pad on the right
		case '-':
			padc = '-';
  80129c:	c6 45 d4 2d          	movb   $0x2d,-0x2c(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012a0:	8d 47 01             	lea    0x1(%edi),%eax
  8012a3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  8012a6:	0f b6 07             	movzbl (%edi),%eax
  8012a9:	0f b6 c8             	movzbl %al,%ecx
  8012ac:	83 e8 23             	sub    $0x23,%eax
  8012af:	3c 55                	cmp    $0x55,%al
  8012b1:	0f 87 64 03 00 00    	ja     80161b <vprintfmt+0x3d4>
  8012b7:	0f b6 c0             	movzbl %al,%eax
  8012ba:	ff 24 85 60 20 80 00 	jmp    *0x802060(,%eax,4)
  8012c1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
  8012c4:	c6 45 d4 30          	movb   $0x30,-0x2c(%ebp)
  8012c8:	eb d6                	jmp    8012a0 <vprintfmt+0x59>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012ca:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8012cd:	b8 00 00 00 00       	mov    $0x0,%eax
  8012d2:	89 55 e4             	mov    %edx,-0x1c(%ebp)
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
  8012d5:	8d 04 80             	lea    (%eax,%eax,4),%eax
  8012d8:	8d 44 41 d0          	lea    -0x30(%ecx,%eax,2),%eax
				ch = *fmt;
  8012dc:	0f be 0f             	movsbl (%edi),%ecx
				if (ch < '0' || ch > '9')
  8012df:	8d 51 d0             	lea    -0x30(%ecx),%edx
  8012e2:	83 fa 09             	cmp    $0x9,%edx
  8012e5:	77 39                	ja     801320 <vprintfmt+0xd9>
		case '5':
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
  8012e7:	83 c7 01             	add    $0x1,%edi
				precision = precision * 10 + ch - '0';
				ch = *fmt;
				if (ch < '0' || ch > '9')
					break;
			}
  8012ea:	eb e9                	jmp    8012d5 <vprintfmt+0x8e>
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
  8012ec:	8b 45 14             	mov    0x14(%ebp),%eax
  8012ef:	8d 48 04             	lea    0x4(%eax),%ecx
  8012f2:	89 4d 14             	mov    %ecx,0x14(%ebp)
  8012f5:	8b 00                	mov    (%eax),%eax
  8012f7:	89 45 c8             	mov    %eax,-0x38(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8012fa:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
  8012fd:	eb 27                	jmp    801326 <vprintfmt+0xdf>
  8012ff:	8b 45 e0             	mov    -0x20(%ebp),%eax
  801302:	85 c0                	test   %eax,%eax
  801304:	b9 00 00 00 00       	mov    $0x0,%ecx
  801309:	0f 49 c8             	cmovns %eax,%ecx
  80130c:	89 4d e0             	mov    %ecx,-0x20(%ebp)
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  80130f:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801312:	eb 8c                	jmp    8012a0 <vprintfmt+0x59>
  801314:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
  801317:	c7 45 d8 01 00 00 00 	movl   $0x1,-0x28(%ebp)
			goto reswitch;
  80131e:	eb 80                	jmp    8012a0 <vprintfmt+0x59>
  801320:	8b 55 e4             	mov    -0x1c(%ebp),%edx
  801323:	89 45 c8             	mov    %eax,-0x38(%ebp)

		process_precision:
			if (width < 0)
  801326:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  80132a:	0f 89 70 ff ff ff    	jns    8012a0 <vprintfmt+0x59>
				width = precision, precision = -1;
  801330:	8b 45 c8             	mov    -0x38(%ebp),%eax
  801333:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801336:	c7 45 c8 ff ff ff ff 	movl   $0xffffffff,-0x38(%ebp)
  80133d:	e9 5e ff ff ff       	jmp    8012a0 <vprintfmt+0x59>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
  801342:	83 c2 01             	add    $0x1,%edx
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801345:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
  801348:	e9 53 ff ff ff       	jmp    8012a0 <vprintfmt+0x59>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
  80134d:	8b 45 14             	mov    0x14(%ebp),%eax
  801350:	8d 50 04             	lea    0x4(%eax),%edx
  801353:	89 55 14             	mov    %edx,0x14(%ebp)
  801356:	83 ec 08             	sub    $0x8,%esp
  801359:	53                   	push   %ebx
  80135a:	ff 30                	pushl  (%eax)
  80135c:	ff d6                	call   *%esi
			break;
  80135e:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801361:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			goto reswitch;

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
			break;
  801364:	e9 04 ff ff ff       	jmp    80126d <vprintfmt+0x26>

		// error message
		case 'e':
			err = va_arg(ap, int);
  801369:	8b 45 14             	mov    0x14(%ebp),%eax
  80136c:	8d 50 04             	lea    0x4(%eax),%edx
  80136f:	89 55 14             	mov    %edx,0x14(%ebp)
  801372:	8b 00                	mov    (%eax),%eax
  801374:	99                   	cltd   
  801375:	31 d0                	xor    %edx,%eax
  801377:	29 d0                	sub    %edx,%eax
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
  801379:	83 f8 0f             	cmp    $0xf,%eax
  80137c:	7f 0b                	jg     801389 <vprintfmt+0x142>
  80137e:	8b 14 85 c0 21 80 00 	mov    0x8021c0(,%eax,4),%edx
  801385:	85 d2                	test   %edx,%edx
  801387:	75 18                	jne    8013a1 <vprintfmt+0x15a>
				printfmt(putch, putdat, "error %d", err);
  801389:	50                   	push   %eax
  80138a:	68 3f 1f 80 00       	push   $0x801f3f
  80138f:	53                   	push   %ebx
  801390:	56                   	push   %esi
  801391:	e8 94 fe ff ff       	call   80122a <printfmt>
  801396:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801399:	8b 7d e4             	mov    -0x1c(%ebp),%edi
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
  80139c:	e9 cc fe ff ff       	jmp    80126d <vprintfmt+0x26>
			else
				printfmt(putch, putdat, "%s", p);
  8013a1:	52                   	push   %edx
  8013a2:	68 bd 1e 80 00       	push   $0x801ebd
  8013a7:	53                   	push   %ebx
  8013a8:	56                   	push   %esi
  8013a9:	e8 7c fe ff ff       	call   80122a <printfmt>
  8013ae:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8013b1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8013b4:	e9 b4 fe ff ff       	jmp    80126d <vprintfmt+0x26>
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
  8013b9:	8b 45 14             	mov    0x14(%ebp),%eax
  8013bc:	8d 50 04             	lea    0x4(%eax),%edx
  8013bf:	89 55 14             	mov    %edx,0x14(%ebp)
  8013c2:	8b 38                	mov    (%eax),%edi
				p = "(null)";
  8013c4:	85 ff                	test   %edi,%edi
  8013c6:	b8 38 1f 80 00       	mov    $0x801f38,%eax
  8013cb:	0f 44 f8             	cmove  %eax,%edi
			if (width > 0 && padc != '-')
  8013ce:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
  8013d2:	0f 8e 94 00 00 00    	jle    80146c <vprintfmt+0x225>
  8013d8:	80 7d d4 2d          	cmpb   $0x2d,-0x2c(%ebp)
  8013dc:	0f 84 98 00 00 00    	je     80147a <vprintfmt+0x233>
				for (width -= strnlen(p, precision); width > 0; width--)
  8013e2:	83 ec 08             	sub    $0x8,%esp
  8013e5:	ff 75 c8             	pushl  -0x38(%ebp)
  8013e8:	57                   	push   %edi
  8013e9:	e8 d0 02 00 00       	call   8016be <strnlen>
  8013ee:	8b 4d e0             	mov    -0x20(%ebp),%ecx
  8013f1:	29 c1                	sub    %eax,%ecx
  8013f3:	89 4d d0             	mov    %ecx,-0x30(%ebp)
  8013f6:	83 c4 10             	add    $0x10,%esp
					putch(padc, putdat);
  8013f9:	0f be 45 d4          	movsbl -0x2c(%ebp),%eax
  8013fd:	89 45 e0             	mov    %eax,-0x20(%ebp)
  801400:	89 7d d4             	mov    %edi,-0x2c(%ebp)
  801403:	89 cf                	mov    %ecx,%edi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801405:	eb 0f                	jmp    801416 <vprintfmt+0x1cf>
					putch(padc, putdat);
  801407:	83 ec 08             	sub    $0x8,%esp
  80140a:	53                   	push   %ebx
  80140b:	ff 75 e0             	pushl  -0x20(%ebp)
  80140e:	ff d6                	call   *%esi
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
  801410:	83 ef 01             	sub    $0x1,%edi
  801413:	83 c4 10             	add    $0x10,%esp
  801416:	85 ff                	test   %edi,%edi
  801418:	7f ed                	jg     801407 <vprintfmt+0x1c0>
  80141a:	8b 7d d4             	mov    -0x2c(%ebp),%edi
  80141d:	8b 4d d0             	mov    -0x30(%ebp),%ecx
  801420:	85 c9                	test   %ecx,%ecx
  801422:	b8 00 00 00 00       	mov    $0x0,%eax
  801427:	0f 49 c1             	cmovns %ecx,%eax
  80142a:	29 c1                	sub    %eax,%ecx
  80142c:	89 75 08             	mov    %esi,0x8(%ebp)
  80142f:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801432:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801435:	89 cb                	mov    %ecx,%ebx
  801437:	eb 4d                	jmp    801486 <vprintfmt+0x23f>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
  801439:	83 7d d8 00          	cmpl   $0x0,-0x28(%ebp)
  80143d:	74 1b                	je     80145a <vprintfmt+0x213>
  80143f:	0f be c0             	movsbl %al,%eax
  801442:	83 e8 20             	sub    $0x20,%eax
  801445:	83 f8 5e             	cmp    $0x5e,%eax
  801448:	76 10                	jbe    80145a <vprintfmt+0x213>
					putch('?', putdat);
  80144a:	83 ec 08             	sub    $0x8,%esp
  80144d:	ff 75 0c             	pushl  0xc(%ebp)
  801450:	6a 3f                	push   $0x3f
  801452:	ff 55 08             	call   *0x8(%ebp)
  801455:	83 c4 10             	add    $0x10,%esp
  801458:	eb 0d                	jmp    801467 <vprintfmt+0x220>
				else
					putch(ch, putdat);
  80145a:	83 ec 08             	sub    $0x8,%esp
  80145d:	ff 75 0c             	pushl  0xc(%ebp)
  801460:	52                   	push   %edx
  801461:	ff 55 08             	call   *0x8(%ebp)
  801464:	83 c4 10             	add    $0x10,%esp
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
  801467:	83 eb 01             	sub    $0x1,%ebx
  80146a:	eb 1a                	jmp    801486 <vprintfmt+0x23f>
  80146c:	89 75 08             	mov    %esi,0x8(%ebp)
  80146f:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801472:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801475:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801478:	eb 0c                	jmp    801486 <vprintfmt+0x23f>
  80147a:	89 75 08             	mov    %esi,0x8(%ebp)
  80147d:	8b 75 c8             	mov    -0x38(%ebp),%esi
  801480:	89 5d 0c             	mov    %ebx,0xc(%ebp)
  801483:	8b 5d e0             	mov    -0x20(%ebp),%ebx
  801486:	83 c7 01             	add    $0x1,%edi
  801489:	0f b6 47 ff          	movzbl -0x1(%edi),%eax
  80148d:	0f be d0             	movsbl %al,%edx
  801490:	85 d2                	test   %edx,%edx
  801492:	74 23                	je     8014b7 <vprintfmt+0x270>
  801494:	85 f6                	test   %esi,%esi
  801496:	78 a1                	js     801439 <vprintfmt+0x1f2>
  801498:	83 ee 01             	sub    $0x1,%esi
  80149b:	79 9c                	jns    801439 <vprintfmt+0x1f2>
  80149d:	89 df                	mov    %ebx,%edi
  80149f:	8b 75 08             	mov    0x8(%ebp),%esi
  8014a2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014a5:	eb 18                	jmp    8014bf <vprintfmt+0x278>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
  8014a7:	83 ec 08             	sub    $0x8,%esp
  8014aa:	53                   	push   %ebx
  8014ab:	6a 20                	push   $0x20
  8014ad:	ff d6                	call   *%esi
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
  8014af:	83 ef 01             	sub    $0x1,%edi
  8014b2:	83 c4 10             	add    $0x10,%esp
  8014b5:	eb 08                	jmp    8014bf <vprintfmt+0x278>
  8014b7:	89 df                	mov    %ebx,%edi
  8014b9:	8b 75 08             	mov    0x8(%ebp),%esi
  8014bc:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  8014bf:	85 ff                	test   %edi,%edi
  8014c1:	7f e4                	jg     8014a7 <vprintfmt+0x260>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  8014c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  8014c6:	e9 a2 fd ff ff       	jmp    80126d <vprintfmt+0x26>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
  8014cb:	83 fa 01             	cmp    $0x1,%edx
  8014ce:	7e 16                	jle    8014e6 <vprintfmt+0x29f>
		return va_arg(*ap, long long);
  8014d0:	8b 45 14             	mov    0x14(%ebp),%eax
  8014d3:	8d 50 08             	lea    0x8(%eax),%edx
  8014d6:	89 55 14             	mov    %edx,0x14(%ebp)
  8014d9:	8b 50 04             	mov    0x4(%eax),%edx
  8014dc:	8b 00                	mov    (%eax),%eax
  8014de:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8014e1:	89 55 cc             	mov    %edx,-0x34(%ebp)
  8014e4:	eb 32                	jmp    801518 <vprintfmt+0x2d1>
	else if (lflag)
  8014e6:	85 d2                	test   %edx,%edx
  8014e8:	74 18                	je     801502 <vprintfmt+0x2bb>
		return va_arg(*ap, long);
  8014ea:	8b 45 14             	mov    0x14(%ebp),%eax
  8014ed:	8d 50 04             	lea    0x4(%eax),%edx
  8014f0:	89 55 14             	mov    %edx,0x14(%ebp)
  8014f3:	8b 00                	mov    (%eax),%eax
  8014f5:	89 45 c8             	mov    %eax,-0x38(%ebp)
  8014f8:	89 c1                	mov    %eax,%ecx
  8014fa:	c1 f9 1f             	sar    $0x1f,%ecx
  8014fd:	89 4d cc             	mov    %ecx,-0x34(%ebp)
  801500:	eb 16                	jmp    801518 <vprintfmt+0x2d1>
	else
		return va_arg(*ap, int);
  801502:	8b 45 14             	mov    0x14(%ebp),%eax
  801505:	8d 50 04             	lea    0x4(%eax),%edx
  801508:	89 55 14             	mov    %edx,0x14(%ebp)
  80150b:	8b 00                	mov    (%eax),%eax
  80150d:	89 45 c8             	mov    %eax,-0x38(%ebp)
  801510:	89 c1                	mov    %eax,%ecx
  801512:	c1 f9 1f             	sar    $0x1f,%ecx
  801515:	89 4d cc             	mov    %ecx,-0x34(%ebp)
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
  801518:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80151b:	8b 55 cc             	mov    -0x34(%ebp),%edx
  80151e:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801521:	89 55 dc             	mov    %edx,-0x24(%ebp)
			if ((long long) num < 0) {
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
  801524:	b8 0a 00 00 00       	mov    $0xa,%eax
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
  801529:	83 7d cc 00          	cmpl   $0x0,-0x34(%ebp)
  80152d:	0f 89 b0 00 00 00    	jns    8015e3 <vprintfmt+0x39c>
				putch('-', putdat);
  801533:	83 ec 08             	sub    $0x8,%esp
  801536:	53                   	push   %ebx
  801537:	6a 2d                	push   $0x2d
  801539:	ff d6                	call   *%esi
				num = -(long long) num;
  80153b:	8b 45 c8             	mov    -0x38(%ebp),%eax
  80153e:	8b 55 cc             	mov    -0x34(%ebp),%edx
  801541:	f7 d8                	neg    %eax
  801543:	83 d2 00             	adc    $0x0,%edx
  801546:	f7 da                	neg    %edx
  801548:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80154b:	89 55 dc             	mov    %edx,-0x24(%ebp)
  80154e:	83 c4 10             	add    $0x10,%esp
			}
			base = 10;
  801551:	b8 0a 00 00 00       	mov    $0xa,%eax
  801556:	e9 88 00 00 00       	jmp    8015e3 <vprintfmt+0x39c>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
  80155b:	8d 45 14             	lea    0x14(%ebp),%eax
  80155e:	e8 70 fc ff ff       	call   8011d3 <getuint>
  801563:	89 45 d8             	mov    %eax,-0x28(%ebp)
  801566:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 10;
  801569:	b8 0a 00 00 00       	mov    $0xa,%eax
			goto number;
  80156e:	eb 73                	jmp    8015e3 <vprintfmt+0x39c>
		// (unsigned) octal
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
  801570:	8d 45 14             	lea    0x14(%ebp),%eax
  801573:	e8 5b fc ff ff       	call   8011d3 <getuint>
  801578:	89 45 d8             	mov    %eax,-0x28(%ebp)
  80157b:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 8;
			//my code end
			putch('X', putdat);
  80157e:	83 ec 08             	sub    $0x8,%esp
  801581:	53                   	push   %ebx
  801582:	6a 58                	push   $0x58
  801584:	ff d6                	call   *%esi
			putch('X', putdat);
  801586:	83 c4 08             	add    $0x8,%esp
  801589:	53                   	push   %ebx
  80158a:	6a 58                	push   $0x58
  80158c:	ff d6                	call   *%esi
			putch('X', putdat);
  80158e:	83 c4 08             	add    $0x8,%esp
  801591:	53                   	push   %ebx
  801592:	6a 58                	push   $0x58
  801594:	ff d6                	call   *%esi
			goto number;
  801596:	83 c4 10             	add    $0x10,%esp
		case 'o':

			// Replace this with your code.
			//my code here start
			num = getuint(&ap,lflag);
			base = 8;
  801599:	b8 08 00 00 00       	mov    $0x8,%eax
			//my code end
			putch('X', putdat);
			putch('X', putdat);
			putch('X', putdat);
			goto number;
  80159e:	eb 43                	jmp    8015e3 <vprintfmt+0x39c>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
  8015a0:	83 ec 08             	sub    $0x8,%esp
  8015a3:	53                   	push   %ebx
  8015a4:	6a 30                	push   $0x30
  8015a6:	ff d6                	call   *%esi
			putch('x', putdat);
  8015a8:	83 c4 08             	add    $0x8,%esp
  8015ab:	53                   	push   %ebx
  8015ac:	6a 78                	push   $0x78
  8015ae:	ff d6                	call   *%esi
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
  8015b0:	8b 45 14             	mov    0x14(%ebp),%eax
  8015b3:	8d 50 04             	lea    0x4(%eax),%edx
  8015b6:	89 55 14             	mov    %edx,0x14(%ebp)

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
  8015b9:	8b 00                	mov    (%eax),%eax
  8015bb:	ba 00 00 00 00       	mov    $0x0,%edx
  8015c0:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015c3:	89 55 dc             	mov    %edx,-0x24(%ebp)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
			goto number;
  8015c6:	83 c4 10             	add    $0x10,%esp
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
			base = 16;
  8015c9:	b8 10 00 00 00       	mov    $0x10,%eax
			goto number;
  8015ce:	eb 13                	jmp    8015e3 <vprintfmt+0x39c>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
  8015d0:	8d 45 14             	lea    0x14(%ebp),%eax
  8015d3:	e8 fb fb ff ff       	call   8011d3 <getuint>
  8015d8:	89 45 d8             	mov    %eax,-0x28(%ebp)
  8015db:	89 55 dc             	mov    %edx,-0x24(%ebp)
			base = 16;
  8015de:	b8 10 00 00 00       	mov    $0x10,%eax
		number:
			printnum(putch, putdat, num, base, width, padc);
  8015e3:	83 ec 0c             	sub    $0xc,%esp
  8015e6:	0f be 55 d4          	movsbl -0x2c(%ebp),%edx
  8015ea:	52                   	push   %edx
  8015eb:	ff 75 e0             	pushl  -0x20(%ebp)
  8015ee:	50                   	push   %eax
  8015ef:	ff 75 dc             	pushl  -0x24(%ebp)
  8015f2:	ff 75 d8             	pushl  -0x28(%ebp)
  8015f5:	89 da                	mov    %ebx,%edx
  8015f7:	89 f0                	mov    %esi,%eax
  8015f9:	e8 26 fb ff ff       	call   801124 <printnum>
			break;
  8015fe:	83 c4 20             	add    $0x20,%esp
  801601:	8b 7d e4             	mov    -0x1c(%ebp),%edi
  801604:	e9 64 fc ff ff       	jmp    80126d <vprintfmt+0x26>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
  801609:	83 ec 08             	sub    $0x8,%esp
  80160c:	53                   	push   %ebx
  80160d:	51                   	push   %ecx
  80160e:	ff d6                	call   *%esi
			break;
  801610:	83 c4 10             	add    $0x10,%esp
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
  801613:	8b 7d e4             	mov    -0x1c(%ebp),%edi
			break;

		// escaped '%' character
		case '%':
			putch(ch, putdat);
			break;
  801616:	e9 52 fc ff ff       	jmp    80126d <vprintfmt+0x26>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
  80161b:	83 ec 08             	sub    $0x8,%esp
  80161e:	53                   	push   %ebx
  80161f:	6a 25                	push   $0x25
  801621:	ff d6                	call   *%esi
			for (fmt--; fmt[-1] != '%'; fmt--)
  801623:	83 c4 10             	add    $0x10,%esp
  801626:	eb 03                	jmp    80162b <vprintfmt+0x3e4>
  801628:	83 ef 01             	sub    $0x1,%edi
  80162b:	80 7f ff 25          	cmpb   $0x25,-0x1(%edi)
  80162f:	75 f7                	jne    801628 <vprintfmt+0x3e1>
  801631:	e9 37 fc ff ff       	jmp    80126d <vprintfmt+0x26>
				/* do nothing */;
			break;
		}
	}
}
  801636:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801639:	5b                   	pop    %ebx
  80163a:	5e                   	pop    %esi
  80163b:	5f                   	pop    %edi
  80163c:	5d                   	pop    %ebp
  80163d:	c3                   	ret    

0080163e <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
  80163e:	55                   	push   %ebp
  80163f:	89 e5                	mov    %esp,%ebp
  801641:	83 ec 18             	sub    $0x18,%esp
  801644:	8b 45 08             	mov    0x8(%ebp),%eax
  801647:	8b 55 0c             	mov    0xc(%ebp),%edx
	struct sprintbuf b = {buf, buf+n-1, 0};
  80164a:	89 45 ec             	mov    %eax,-0x14(%ebp)
  80164d:	8d 4c 10 ff          	lea    -0x1(%eax,%edx,1),%ecx
  801651:	89 4d f0             	mov    %ecx,-0x10(%ebp)
  801654:	c7 45 f4 00 00 00 00 	movl   $0x0,-0xc(%ebp)

	if (buf == NULL || n < 1)
  80165b:	85 c0                	test   %eax,%eax
  80165d:	74 26                	je     801685 <vsnprintf+0x47>
  80165f:	85 d2                	test   %edx,%edx
  801661:	7e 22                	jle    801685 <vsnprintf+0x47>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
  801663:	ff 75 14             	pushl  0x14(%ebp)
  801666:	ff 75 10             	pushl  0x10(%ebp)
  801669:	8d 45 ec             	lea    -0x14(%ebp),%eax
  80166c:	50                   	push   %eax
  80166d:	68 0d 12 80 00       	push   $0x80120d
  801672:	e8 d0 fb ff ff       	call   801247 <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
  801677:	8b 45 ec             	mov    -0x14(%ebp),%eax
  80167a:	c6 00 00             	movb   $0x0,(%eax)

	return b.cnt;
  80167d:	8b 45 f4             	mov    -0xc(%ebp),%eax
  801680:	83 c4 10             	add    $0x10,%esp
  801683:	eb 05                	jmp    80168a <vsnprintf+0x4c>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
  801685:	b8 fd ff ff ff       	mov    $0xfffffffd,%eax

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
  80168a:	c9                   	leave  
  80168b:	c3                   	ret    

0080168c <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
  80168c:	55                   	push   %ebp
  80168d:	89 e5                	mov    %esp,%ebp
  80168f:	83 ec 08             	sub    $0x8,%esp
	va_list ap;
	int rc;

	va_start(ap, fmt);
  801692:	8d 45 14             	lea    0x14(%ebp),%eax
	rc = vsnprintf(buf, n, fmt, ap);
  801695:	50                   	push   %eax
  801696:	ff 75 10             	pushl  0x10(%ebp)
  801699:	ff 75 0c             	pushl  0xc(%ebp)
  80169c:	ff 75 08             	pushl  0x8(%ebp)
  80169f:	e8 9a ff ff ff       	call   80163e <vsnprintf>
	va_end(ap);

	return rc;
}
  8016a4:	c9                   	leave  
  8016a5:	c3                   	ret    

008016a6 <strlen>:
// Primespipe runs 3x faster this way.
#define ASM 1

int
strlen(const char *s)
{
  8016a6:	55                   	push   %ebp
  8016a7:	89 e5                	mov    %esp,%ebp
  8016a9:	8b 55 08             	mov    0x8(%ebp),%edx
	int n;

	for (n = 0; *s != '\0'; s++)
  8016ac:	b8 00 00 00 00       	mov    $0x0,%eax
  8016b1:	eb 03                	jmp    8016b6 <strlen+0x10>
		n++;
  8016b3:	83 c0 01             	add    $0x1,%eax
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
  8016b6:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
  8016ba:	75 f7                	jne    8016b3 <strlen+0xd>
		n++;
	return n;
}
  8016bc:	5d                   	pop    %ebp
  8016bd:	c3                   	ret    

008016be <strnlen>:

int
strnlen(const char *s, size_t size)
{
  8016be:	55                   	push   %ebp
  8016bf:	89 e5                	mov    %esp,%ebp
  8016c1:	8b 4d 08             	mov    0x8(%ebp),%ecx
  8016c4:	8b 45 0c             	mov    0xc(%ebp),%eax
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016c7:	ba 00 00 00 00       	mov    $0x0,%edx
  8016cc:	eb 03                	jmp    8016d1 <strnlen+0x13>
		n++;
  8016ce:	83 c2 01             	add    $0x1,%edx
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
  8016d1:	39 c2                	cmp    %eax,%edx
  8016d3:	74 08                	je     8016dd <strnlen+0x1f>
  8016d5:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8016d9:	75 f3                	jne    8016ce <strnlen+0x10>
  8016db:	89 d0                	mov    %edx,%eax
		n++;
	return n;
}
  8016dd:	5d                   	pop    %ebp
  8016de:	c3                   	ret    

008016df <strcpy>:

char *
strcpy(char *dst, const char *src)
{
  8016df:	55                   	push   %ebp
  8016e0:	89 e5                	mov    %esp,%ebp
  8016e2:	53                   	push   %ebx
  8016e3:	8b 45 08             	mov    0x8(%ebp),%eax
  8016e6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
  8016e9:	89 c2                	mov    %eax,%edx
  8016eb:	83 c2 01             	add    $0x1,%edx
  8016ee:	83 c1 01             	add    $0x1,%ecx
  8016f1:	0f b6 59 ff          	movzbl -0x1(%ecx),%ebx
  8016f5:	88 5a ff             	mov    %bl,-0x1(%edx)
  8016f8:	84 db                	test   %bl,%bl
  8016fa:	75 ef                	jne    8016eb <strcpy+0xc>
		/* do nothing */;
	return ret;
}
  8016fc:	5b                   	pop    %ebx
  8016fd:	5d                   	pop    %ebp
  8016fe:	c3                   	ret    

008016ff <strcat>:

char *
strcat(char *dst, const char *src)
{
  8016ff:	55                   	push   %ebp
  801700:	89 e5                	mov    %esp,%ebp
  801702:	53                   	push   %ebx
  801703:	8b 5d 08             	mov    0x8(%ebp),%ebx
	int len = strlen(dst);
  801706:	53                   	push   %ebx
  801707:	e8 9a ff ff ff       	call   8016a6 <strlen>
  80170c:	83 c4 04             	add    $0x4,%esp
	strcpy(dst + len, src);
  80170f:	ff 75 0c             	pushl  0xc(%ebp)
  801712:	01 d8                	add    %ebx,%eax
  801714:	50                   	push   %eax
  801715:	e8 c5 ff ff ff       	call   8016df <strcpy>
	return dst;
}
  80171a:	89 d8                	mov    %ebx,%eax
  80171c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
  80171f:	c9                   	leave  
  801720:	c3                   	ret    

00801721 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
  801721:	55                   	push   %ebp
  801722:	89 e5                	mov    %esp,%ebp
  801724:	56                   	push   %esi
  801725:	53                   	push   %ebx
  801726:	8b 75 08             	mov    0x8(%ebp),%esi
  801729:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  80172c:	89 f3                	mov    %esi,%ebx
  80172e:	03 5d 10             	add    0x10(%ebp),%ebx
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801731:	89 f2                	mov    %esi,%edx
  801733:	eb 0f                	jmp    801744 <strncpy+0x23>
		*dst++ = *src;
  801735:	83 c2 01             	add    $0x1,%edx
  801738:	0f b6 01             	movzbl (%ecx),%eax
  80173b:	88 42 ff             	mov    %al,-0x1(%edx)
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
  80173e:	80 39 01             	cmpb   $0x1,(%ecx)
  801741:	83 d9 ff             	sbb    $0xffffffff,%ecx
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
  801744:	39 da                	cmp    %ebx,%edx
  801746:	75 ed                	jne    801735 <strncpy+0x14>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
  801748:	89 f0                	mov    %esi,%eax
  80174a:	5b                   	pop    %ebx
  80174b:	5e                   	pop    %esi
  80174c:	5d                   	pop    %ebp
  80174d:	c3                   	ret    

0080174e <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
  80174e:	55                   	push   %ebp
  80174f:	89 e5                	mov    %esp,%ebp
  801751:	56                   	push   %esi
  801752:	53                   	push   %ebx
  801753:	8b 75 08             	mov    0x8(%ebp),%esi
  801756:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  801759:	8b 55 10             	mov    0x10(%ebp),%edx
  80175c:	89 f0                	mov    %esi,%eax
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
  80175e:	85 d2                	test   %edx,%edx
  801760:	74 21                	je     801783 <strlcpy+0x35>
  801762:	8d 44 16 ff          	lea    -0x1(%esi,%edx,1),%eax
  801766:	89 f2                	mov    %esi,%edx
  801768:	eb 09                	jmp    801773 <strlcpy+0x25>
		while (--size > 0 && *src != '\0')
			*dst++ = *src++;
  80176a:	83 c2 01             	add    $0x1,%edx
  80176d:	83 c1 01             	add    $0x1,%ecx
  801770:	88 5a ff             	mov    %bl,-0x1(%edx)
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
  801773:	39 c2                	cmp    %eax,%edx
  801775:	74 09                	je     801780 <strlcpy+0x32>
  801777:	0f b6 19             	movzbl (%ecx),%ebx
  80177a:	84 db                	test   %bl,%bl
  80177c:	75 ec                	jne    80176a <strlcpy+0x1c>
  80177e:	89 d0                	mov    %edx,%eax
			*dst++ = *src++;
		*dst = '\0';
  801780:	c6 00 00             	movb   $0x0,(%eax)
	}
	return dst - dst_in;
  801783:	29 f0                	sub    %esi,%eax
}
  801785:	5b                   	pop    %ebx
  801786:	5e                   	pop    %esi
  801787:	5d                   	pop    %ebp
  801788:	c3                   	ret    

00801789 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  801789:	55                   	push   %ebp
  80178a:	89 e5                	mov    %esp,%ebp
  80178c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  80178f:	8b 55 0c             	mov    0xc(%ebp),%edx
	while (*p && *p == *q)
  801792:	eb 06                	jmp    80179a <strcmp+0x11>
		p++, q++;
  801794:	83 c1 01             	add    $0x1,%ecx
  801797:	83 c2 01             	add    $0x1,%edx
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
  80179a:	0f b6 01             	movzbl (%ecx),%eax
  80179d:	84 c0                	test   %al,%al
  80179f:	74 04                	je     8017a5 <strcmp+0x1c>
  8017a1:	3a 02                	cmp    (%edx),%al
  8017a3:	74 ef                	je     801794 <strcmp+0xb>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
  8017a5:	0f b6 c0             	movzbl %al,%eax
  8017a8:	0f b6 12             	movzbl (%edx),%edx
  8017ab:	29 d0                	sub    %edx,%eax
}
  8017ad:	5d                   	pop    %ebp
  8017ae:	c3                   	ret    

008017af <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
  8017af:	55                   	push   %ebp
  8017b0:	89 e5                	mov    %esp,%ebp
  8017b2:	53                   	push   %ebx
  8017b3:	8b 45 08             	mov    0x8(%ebp),%eax
  8017b6:	8b 55 0c             	mov    0xc(%ebp),%edx
  8017b9:	89 c3                	mov    %eax,%ebx
  8017bb:	03 5d 10             	add    0x10(%ebp),%ebx
	while (n > 0 && *p && *p == *q)
  8017be:	eb 06                	jmp    8017c6 <strncmp+0x17>
		n--, p++, q++;
  8017c0:	83 c0 01             	add    $0x1,%eax
  8017c3:	83 c2 01             	add    $0x1,%edx
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
  8017c6:	39 d8                	cmp    %ebx,%eax
  8017c8:	74 15                	je     8017df <strncmp+0x30>
  8017ca:	0f b6 08             	movzbl (%eax),%ecx
  8017cd:	84 c9                	test   %cl,%cl
  8017cf:	74 04                	je     8017d5 <strncmp+0x26>
  8017d1:	3a 0a                	cmp    (%edx),%cl
  8017d3:	74 eb                	je     8017c0 <strncmp+0x11>
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
  8017d5:	0f b6 00             	movzbl (%eax),%eax
  8017d8:	0f b6 12             	movzbl (%edx),%edx
  8017db:	29 d0                	sub    %edx,%eax
  8017dd:	eb 05                	jmp    8017e4 <strncmp+0x35>
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
  8017df:	b8 00 00 00 00       	mov    $0x0,%eax
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
}
  8017e4:	5b                   	pop    %ebx
  8017e5:	5d                   	pop    %ebp
  8017e6:	c3                   	ret    

008017e7 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
  8017e7:	55                   	push   %ebp
  8017e8:	89 e5                	mov    %esp,%ebp
  8017ea:	8b 45 08             	mov    0x8(%ebp),%eax
  8017ed:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  8017f1:	eb 07                	jmp    8017fa <strchr+0x13>
		if (*s == c)
  8017f3:	38 ca                	cmp    %cl,%dl
  8017f5:	74 0f                	je     801806 <strchr+0x1f>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
  8017f7:	83 c0 01             	add    $0x1,%eax
  8017fa:	0f b6 10             	movzbl (%eax),%edx
  8017fd:	84 d2                	test   %dl,%dl
  8017ff:	75 f2                	jne    8017f3 <strchr+0xc>
		if (*s == c)
			return (char *) s;
	return 0;
  801801:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801806:	5d                   	pop    %ebp
  801807:	c3                   	ret    

00801808 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
  801808:	55                   	push   %ebp
  801809:	89 e5                	mov    %esp,%ebp
  80180b:	8b 45 08             	mov    0x8(%ebp),%eax
  80180e:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
	for (; *s; s++)
  801812:	eb 03                	jmp    801817 <strfind+0xf>
  801814:	83 c0 01             	add    $0x1,%eax
  801817:	0f b6 10             	movzbl (%eax),%edx
		if (*s == c)
  80181a:	38 ca                	cmp    %cl,%dl
  80181c:	74 04                	je     801822 <strfind+0x1a>
  80181e:	84 d2                	test   %dl,%dl
  801820:	75 f2                	jne    801814 <strfind+0xc>
			break;
	return (char *) s;
}
  801822:	5d                   	pop    %ebp
  801823:	c3                   	ret    

00801824 <memset>:

#if ASM
void *
memset(void *v, int c, size_t n)
{
  801824:	55                   	push   %ebp
  801825:	89 e5                	mov    %esp,%ebp
  801827:	57                   	push   %edi
  801828:	56                   	push   %esi
  801829:	53                   	push   %ebx
  80182a:	8b 7d 08             	mov    0x8(%ebp),%edi
  80182d:	8b 4d 10             	mov    0x10(%ebp),%ecx
	char *p;

	if (n == 0)
  801830:	85 c9                	test   %ecx,%ecx
  801832:	74 36                	je     80186a <memset+0x46>
		return v;
	if ((int)v%4 == 0 && n%4 == 0) {
  801834:	f7 c7 03 00 00 00    	test   $0x3,%edi
  80183a:	75 28                	jne    801864 <memset+0x40>
  80183c:	f6 c1 03             	test   $0x3,%cl
  80183f:	75 23                	jne    801864 <memset+0x40>
		c &= 0xFF;
  801841:	0f b6 55 0c          	movzbl 0xc(%ebp),%edx
		c = (c<<24)|(c<<16)|(c<<8)|c;
  801845:	89 d3                	mov    %edx,%ebx
  801847:	c1 e3 08             	shl    $0x8,%ebx
  80184a:	89 d6                	mov    %edx,%esi
  80184c:	c1 e6 18             	shl    $0x18,%esi
  80184f:	89 d0                	mov    %edx,%eax
  801851:	c1 e0 10             	shl    $0x10,%eax
  801854:	09 f0                	or     %esi,%eax
  801856:	09 c2                	or     %eax,%edx
		asm volatile("cld; rep stosl\n"
  801858:	89 d8                	mov    %ebx,%eax
  80185a:	09 d0                	or     %edx,%eax
  80185c:	c1 e9 02             	shr    $0x2,%ecx
  80185f:	fc                   	cld    
  801860:	f3 ab                	rep stos %eax,%es:(%edi)
  801862:	eb 06                	jmp    80186a <memset+0x46>
			:: "D" (v), "a" (c), "c" (n/4)
			: "cc", "memory");
	} else
		asm volatile("cld; rep stosb\n"
  801864:	8b 45 0c             	mov    0xc(%ebp),%eax
  801867:	fc                   	cld    
  801868:	f3 aa                	rep stos %al,%es:(%edi)
			:: "D" (v), "a" (c), "c" (n)
			: "cc", "memory");
	return v;
}
  80186a:	89 f8                	mov    %edi,%eax
  80186c:	5b                   	pop    %ebx
  80186d:	5e                   	pop    %esi
  80186e:	5f                   	pop    %edi
  80186f:	5d                   	pop    %ebp
  801870:	c3                   	ret    

00801871 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
  801871:	55                   	push   %ebp
  801872:	89 e5                	mov    %esp,%ebp
  801874:	57                   	push   %edi
  801875:	56                   	push   %esi
  801876:	8b 45 08             	mov    0x8(%ebp),%eax
  801879:	8b 75 0c             	mov    0xc(%ebp),%esi
  80187c:	8b 4d 10             	mov    0x10(%ebp),%ecx
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
  80187f:	39 c6                	cmp    %eax,%esi
  801881:	73 35                	jae    8018b8 <memmove+0x47>
  801883:	8d 14 0e             	lea    (%esi,%ecx,1),%edx
  801886:	39 d0                	cmp    %edx,%eax
  801888:	73 2e                	jae    8018b8 <memmove+0x47>
		s += n;
		d += n;
  80188a:	8d 3c 08             	lea    (%eax,%ecx,1),%edi
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  80188d:	89 d6                	mov    %edx,%esi
  80188f:	09 fe                	or     %edi,%esi
  801891:	f7 c6 03 00 00 00    	test   $0x3,%esi
  801897:	75 13                	jne    8018ac <memmove+0x3b>
  801899:	f6 c1 03             	test   $0x3,%cl
  80189c:	75 0e                	jne    8018ac <memmove+0x3b>
			asm volatile("std; rep movsl\n"
  80189e:	83 ef 04             	sub    $0x4,%edi
  8018a1:	8d 72 fc             	lea    -0x4(%edx),%esi
  8018a4:	c1 e9 02             	shr    $0x2,%ecx
  8018a7:	fd                   	std    
  8018a8:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018aa:	eb 09                	jmp    8018b5 <memmove+0x44>
				:: "D" (d-4), "S" (s-4), "c" (n/4) : "cc", "memory");
		else
			asm volatile("std; rep movsb\n"
  8018ac:	83 ef 01             	sub    $0x1,%edi
  8018af:	8d 72 ff             	lea    -0x1(%edx),%esi
  8018b2:	fd                   	std    
  8018b3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d-1), "S" (s-1), "c" (n) : "cc", "memory");
		// Some versions of GCC rely on DF being clear
		asm volatile("cld" ::: "cc");
  8018b5:	fc                   	cld    
  8018b6:	eb 1d                	jmp    8018d5 <memmove+0x64>
	} else {
		if ((int)s%4 == 0 && (int)d%4 == 0 && n%4 == 0)
  8018b8:	89 f2                	mov    %esi,%edx
  8018ba:	09 c2                	or     %eax,%edx
  8018bc:	f6 c2 03             	test   $0x3,%dl
  8018bf:	75 0f                	jne    8018d0 <memmove+0x5f>
  8018c1:	f6 c1 03             	test   $0x3,%cl
  8018c4:	75 0a                	jne    8018d0 <memmove+0x5f>
			asm volatile("cld; rep movsl\n"
  8018c6:	c1 e9 02             	shr    $0x2,%ecx
  8018c9:	89 c7                	mov    %eax,%edi
  8018cb:	fc                   	cld    
  8018cc:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  8018ce:	eb 05                	jmp    8018d5 <memmove+0x64>
				:: "D" (d), "S" (s), "c" (n/4) : "cc", "memory");
		else
			asm volatile("cld; rep movsb\n"
  8018d0:	89 c7                	mov    %eax,%edi
  8018d2:	fc                   	cld    
  8018d3:	f3 a4                	rep movsb %ds:(%esi),%es:(%edi)
				:: "D" (d), "S" (s), "c" (n) : "cc", "memory");
	}
	return dst;
}
  8018d5:	5e                   	pop    %esi
  8018d6:	5f                   	pop    %edi
  8018d7:	5d                   	pop    %ebp
  8018d8:	c3                   	ret    

008018d9 <memcpy>:
}
#endif

void *
memcpy(void *dst, const void *src, size_t n)
{
  8018d9:	55                   	push   %ebp
  8018da:	89 e5                	mov    %esp,%ebp
	return memmove(dst, src, n);
  8018dc:	ff 75 10             	pushl  0x10(%ebp)
  8018df:	ff 75 0c             	pushl  0xc(%ebp)
  8018e2:	ff 75 08             	pushl  0x8(%ebp)
  8018e5:	e8 87 ff ff ff       	call   801871 <memmove>
}
  8018ea:	c9                   	leave  
  8018eb:	c3                   	ret    

008018ec <memcmp>:

int
memcmp(const void *v1, const void *v2, size_t n)
{
  8018ec:	55                   	push   %ebp
  8018ed:	89 e5                	mov    %esp,%ebp
  8018ef:	56                   	push   %esi
  8018f0:	53                   	push   %ebx
  8018f1:	8b 45 08             	mov    0x8(%ebp),%eax
  8018f4:	8b 55 0c             	mov    0xc(%ebp),%edx
  8018f7:	89 c6                	mov    %eax,%esi
  8018f9:	03 75 10             	add    0x10(%ebp),%esi
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  8018fc:	eb 1a                	jmp    801918 <memcmp+0x2c>
		if (*s1 != *s2)
  8018fe:	0f b6 08             	movzbl (%eax),%ecx
  801901:	0f b6 1a             	movzbl (%edx),%ebx
  801904:	38 d9                	cmp    %bl,%cl
  801906:	74 0a                	je     801912 <memcmp+0x26>
			return (int) *s1 - (int) *s2;
  801908:	0f b6 c1             	movzbl %cl,%eax
  80190b:	0f b6 db             	movzbl %bl,%ebx
  80190e:	29 d8                	sub    %ebx,%eax
  801910:	eb 0f                	jmp    801921 <memcmp+0x35>
		s1++, s2++;
  801912:	83 c0 01             	add    $0x1,%eax
  801915:	83 c2 01             	add    $0x1,%edx
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
  801918:	39 f0                	cmp    %esi,%eax
  80191a:	75 e2                	jne    8018fe <memcmp+0x12>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
  80191c:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801921:	5b                   	pop    %ebx
  801922:	5e                   	pop    %esi
  801923:	5d                   	pop    %ebp
  801924:	c3                   	ret    

00801925 <memfind>:

void *
memfind(const void *s, int c, size_t n)
{
  801925:	55                   	push   %ebp
  801926:	89 e5                	mov    %esp,%ebp
  801928:	53                   	push   %ebx
  801929:	8b 45 08             	mov    0x8(%ebp),%eax
	const void *ends = (const char *) s + n;
  80192c:	89 c1                	mov    %eax,%ecx
  80192e:	03 4d 10             	add    0x10(%ebp),%ecx
	for (; s < ends; s++)
		if (*(const unsigned char *) s == (unsigned char) c)
  801931:	0f b6 5d 0c          	movzbl 0xc(%ebp),%ebx

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  801935:	eb 0a                	jmp    801941 <memfind+0x1c>
		if (*(const unsigned char *) s == (unsigned char) c)
  801937:	0f b6 10             	movzbl (%eax),%edx
  80193a:	39 da                	cmp    %ebx,%edx
  80193c:	74 07                	je     801945 <memfind+0x20>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
  80193e:	83 c0 01             	add    $0x1,%eax
  801941:	39 c8                	cmp    %ecx,%eax
  801943:	72 f2                	jb     801937 <memfind+0x12>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
  801945:	5b                   	pop    %ebx
  801946:	5d                   	pop    %ebp
  801947:	c3                   	ret    

00801948 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
  801948:	55                   	push   %ebp
  801949:	89 e5                	mov    %esp,%ebp
  80194b:	57                   	push   %edi
  80194c:	56                   	push   %esi
  80194d:	53                   	push   %ebx
  80194e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  801951:	8b 5d 10             	mov    0x10(%ebp),%ebx
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801954:	eb 03                	jmp    801959 <strtol+0x11>
		s++;
  801956:	83 c1 01             	add    $0x1,%ecx
{
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
  801959:	0f b6 01             	movzbl (%ecx),%eax
  80195c:	3c 20                	cmp    $0x20,%al
  80195e:	74 f6                	je     801956 <strtol+0xe>
  801960:	3c 09                	cmp    $0x9,%al
  801962:	74 f2                	je     801956 <strtol+0xe>
		s++;

	// plus/minus sign
	if (*s == '+')
  801964:	3c 2b                	cmp    $0x2b,%al
  801966:	75 0a                	jne    801972 <strtol+0x2a>
		s++;
  801968:	83 c1 01             	add    $0x1,%ecx
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
  80196b:	bf 00 00 00 00       	mov    $0x0,%edi
  801970:	eb 11                	jmp    801983 <strtol+0x3b>
  801972:	bf 00 00 00 00       	mov    $0x0,%edi
		s++;

	// plus/minus sign
	if (*s == '+')
		s++;
	else if (*s == '-')
  801977:	3c 2d                	cmp    $0x2d,%al
  801979:	75 08                	jne    801983 <strtol+0x3b>
		s++, neg = 1;
  80197b:	83 c1 01             	add    $0x1,%ecx
  80197e:	bf 01 00 00 00       	mov    $0x1,%edi

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
  801983:	f7 c3 ef ff ff ff    	test   $0xffffffef,%ebx
  801989:	75 15                	jne    8019a0 <strtol+0x58>
  80198b:	80 39 30             	cmpb   $0x30,(%ecx)
  80198e:	75 10                	jne    8019a0 <strtol+0x58>
  801990:	80 79 01 78          	cmpb   $0x78,0x1(%ecx)
  801994:	75 7c                	jne    801a12 <strtol+0xca>
		s += 2, base = 16;
  801996:	83 c1 02             	add    $0x2,%ecx
  801999:	bb 10 00 00 00       	mov    $0x10,%ebx
  80199e:	eb 16                	jmp    8019b6 <strtol+0x6e>
	else if (base == 0 && s[0] == '0')
  8019a0:	85 db                	test   %ebx,%ebx
  8019a2:	75 12                	jne    8019b6 <strtol+0x6e>
		s++, base = 8;
	else if (base == 0)
		base = 10;
  8019a4:	bb 0a 00 00 00       	mov    $0xa,%ebx
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  8019a9:	80 39 30             	cmpb   $0x30,(%ecx)
  8019ac:	75 08                	jne    8019b6 <strtol+0x6e>
		s++, base = 8;
  8019ae:	83 c1 01             	add    $0x1,%ecx
  8019b1:	bb 08 00 00 00       	mov    $0x8,%ebx
	else if (base == 0)
		base = 10;
  8019b6:	b8 00 00 00 00       	mov    $0x0,%eax
  8019bb:	89 5d 10             	mov    %ebx,0x10(%ebp)

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
  8019be:	0f b6 11             	movzbl (%ecx),%edx
  8019c1:	8d 72 d0             	lea    -0x30(%edx),%esi
  8019c4:	89 f3                	mov    %esi,%ebx
  8019c6:	80 fb 09             	cmp    $0x9,%bl
  8019c9:	77 08                	ja     8019d3 <strtol+0x8b>
			dig = *s - '0';
  8019cb:	0f be d2             	movsbl %dl,%edx
  8019ce:	83 ea 30             	sub    $0x30,%edx
  8019d1:	eb 22                	jmp    8019f5 <strtol+0xad>
		else if (*s >= 'a' && *s <= 'z')
  8019d3:	8d 72 9f             	lea    -0x61(%edx),%esi
  8019d6:	89 f3                	mov    %esi,%ebx
  8019d8:	80 fb 19             	cmp    $0x19,%bl
  8019db:	77 08                	ja     8019e5 <strtol+0x9d>
			dig = *s - 'a' + 10;
  8019dd:	0f be d2             	movsbl %dl,%edx
  8019e0:	83 ea 57             	sub    $0x57,%edx
  8019e3:	eb 10                	jmp    8019f5 <strtol+0xad>
		else if (*s >= 'A' && *s <= 'Z')
  8019e5:	8d 72 bf             	lea    -0x41(%edx),%esi
  8019e8:	89 f3                	mov    %esi,%ebx
  8019ea:	80 fb 19             	cmp    $0x19,%bl
  8019ed:	77 16                	ja     801a05 <strtol+0xbd>
			dig = *s - 'A' + 10;
  8019ef:	0f be d2             	movsbl %dl,%edx
  8019f2:	83 ea 37             	sub    $0x37,%edx
		else
			break;
		if (dig >= base)
  8019f5:	3b 55 10             	cmp    0x10(%ebp),%edx
  8019f8:	7d 0b                	jge    801a05 <strtol+0xbd>
			break;
		s++, val = (val * base) + dig;
  8019fa:	83 c1 01             	add    $0x1,%ecx
  8019fd:	0f af 45 10          	imul   0x10(%ebp),%eax
  801a01:	01 d0                	add    %edx,%eax
		// we don't properly detect overflow!
	}
  801a03:	eb b9                	jmp    8019be <strtol+0x76>

	if (endptr)
  801a05:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
  801a09:	74 0d                	je     801a18 <strtol+0xd0>
		*endptr = (char *) s;
  801a0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a0e:	89 0e                	mov    %ecx,(%esi)
  801a10:	eb 06                	jmp    801a18 <strtol+0xd0>
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
  801a12:	85 db                	test   %ebx,%ebx
  801a14:	74 98                	je     8019ae <strtol+0x66>
  801a16:	eb 9e                	jmp    8019b6 <strtol+0x6e>
		// we don't properly detect overflow!
	}

	if (endptr)
		*endptr = (char *) s;
	return (neg ? -val : val);
  801a18:	89 c2                	mov    %eax,%edx
  801a1a:	f7 da                	neg    %edx
  801a1c:	85 ff                	test   %edi,%edi
  801a1e:	0f 45 c2             	cmovne %edx,%eax
}
  801a21:	5b                   	pop    %ebx
  801a22:	5e                   	pop    %esi
  801a23:	5f                   	pop    %edi
  801a24:	5d                   	pop    %ebp
  801a25:	c3                   	ret    

00801a26 <ipc_recv>:
//   If 'pg' is null, pass sys_ipc_recv a value that it will understand
//   as meaning "no page".  (Zero is not the right value, since that's
//   a perfectly valid place to map a page.)
int32_t
ipc_recv(envid_t *from_env_store, void *pg, int *perm_store)
{
  801a26:	55                   	push   %ebp
  801a27:	89 e5                	mov    %esp,%ebp
  801a29:	56                   	push   %esi
  801a2a:	53                   	push   %ebx
  801a2b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  801a2e:	8b 75 10             	mov    0x10(%ebp),%esi
//`sys_ipc_try_send(envid_t envid, uint32_t value, void *srcva, int perm)

	// LAB 4: Your code here.
//	cprintf("sys_ipc_recv(pg)\n");
	sys_ipc_recv(pg);
  801a31:	83 ec 0c             	sub    $0xc,%esp
  801a34:	ff 75 0c             	pushl  0xc(%ebp)
  801a37:	e8 d7 e8 ff ff       	call   800313 <sys_ipc_recv>
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
  801a3c:	83 c4 10             	add    $0x10,%esp
  801a3f:	85 f6                	test   %esi,%esi
  801a41:	74 1c                	je     801a5f <ipc_recv+0x39>
		*perm_store = thisenv->env_ipc_perm;
  801a43:	a1 04 40 80 00       	mov    0x804004,%eax
  801a48:	8b 40 78             	mov    0x78(%eax),%eax
  801a4b:	89 06                	mov    %eax,(%esi)
  801a4d:	eb 10                	jmp    801a5f <ipc_recv+0x39>
	}
	while(thisenv->env_ipc_from == 0){
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
  801a4f:	83 ec 0c             	sub    $0xc,%esp
  801a52:	68 20 22 80 00       	push   $0x802220
  801a57:	e8 b4 f6 ff ff       	call   801110 <cprintf>
  801a5c:	83 c4 10             	add    $0x10,%esp
	sys_ipc_recv(pg);
//	cprintf("sys_ipc_recv(pg) done.\n");	
	if(perm_store != NULL){
		*perm_store = thisenv->env_ipc_perm;
	}
	while(thisenv->env_ipc_from == 0){
  801a5f:	a1 04 40 80 00       	mov    0x804004,%eax
  801a64:	8b 50 74             	mov    0x74(%eax),%edx
  801a67:	85 d2                	test   %edx,%edx
  801a69:	74 e4                	je     801a4f <ipc_recv+0x29>
		cprintf("recv waitting. ");//*from_env_store = thisenv->env_ipc_from;
	}	
	if(from_env_store != NULL){
  801a6b:	85 db                	test   %ebx,%ebx
  801a6d:	74 05                	je     801a74 <ipc_recv+0x4e>
		*from_env_store = thisenv->env_ipc_from;
  801a6f:	8b 40 74             	mov    0x74(%eax),%eax
  801a72:	89 03                	mov    %eax,(%ebx)
	}
	//sys_ipc_recv(pg);		
//	cprintf("lib/ipc.c:ipc_recv().\n");
	//panic("ipc_recv not implemented");
	return thisenv->env_ipc_value;
  801a74:	a1 04 40 80 00       	mov    0x804004,%eax
  801a79:	8b 40 70             	mov    0x70(%eax),%eax

}
  801a7c:	8d 65 f8             	lea    -0x8(%ebp),%esp
  801a7f:	5b                   	pop    %ebx
  801a80:	5e                   	pop    %esi
  801a81:	5d                   	pop    %ebp
  801a82:	c3                   	ret    

00801a83 <ipc_send>:
//   Use sys_yield() to be CPU-friendly.
//   If 'pg' is null, pass sys_ipc_try_send a value that it will understand
//   as meaning "no page".  (Zero is not the right value.)
void
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
  801a83:	55                   	push   %ebp
  801a84:	89 e5                	mov    %esp,%ebp
  801a86:	57                   	push   %edi
  801a87:	56                   	push   %esi
  801a88:	53                   	push   %ebx
  801a89:	83 ec 0c             	sub    $0xc,%esp
  801a8c:	8b 7d 08             	mov    0x8(%ebp),%edi
  801a8f:	8b 75 0c             	mov    0xc(%ebp),%esi
  801a92:	8b 5d 10             	mov    0x10(%ebp),%ebx
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
//		cprintf("sending.");		
		if(pg == NULL){
  801a95:	85 db                	test   %ebx,%ebx
  801a97:	75 13                	jne    801aac <ipc_send+0x29>
			retv = sys_ipc_try_send(to_env, val, (void*)UTOP, 0);
  801a99:	6a 00                	push   $0x0
  801a9b:	68 00 00 c0 ee       	push   $0xeec00000
  801aa0:	56                   	push   %esi
  801aa1:	57                   	push   %edi
  801aa2:	e8 49 e8 ff ff       	call   8002f0 <sys_ipc_try_send>
  801aa7:	83 c4 10             	add    $0x10,%esp
  801aaa:	eb 0e                	jmp    801aba <ipc_send+0x37>
		}else{
			retv = sys_ipc_try_send(to_env, val, pg, perm);
  801aac:	ff 75 14             	pushl  0x14(%ebp)
  801aaf:	53                   	push   %ebx
  801ab0:	56                   	push   %esi
  801ab1:	57                   	push   %edi
  801ab2:	e8 39 e8 ff ff       	call   8002f0 <sys_ipc_try_send>
  801ab7:	83 c4 10             	add    $0x10,%esp
ipc_send(envid_t to_env, uint32_t val, void *pg, int perm)
{
	// LAB 4: Your code here.
	int retv = -1;
	int cnt = 10;
	while(retv != 0){
  801aba:	85 c0                	test   %eax,%eax
  801abc:	75 d7                	jne    801a95 <ipc_send+0x12>
		//cprintf("send retv is:%d\n",retv);
		//cprintf("sending waiting. ");

	}
	//panic("ipc_send not implemented");
}
  801abe:	8d 65 f4             	lea    -0xc(%ebp),%esp
  801ac1:	5b                   	pop    %ebx
  801ac2:	5e                   	pop    %esi
  801ac3:	5f                   	pop    %edi
  801ac4:	5d                   	pop    %ebp
  801ac5:	c3                   	ret    

00801ac6 <ipc_find_env>:
// Find the first environment of the given type.  We'll use this to
// find special environments.
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
  801ac6:	55                   	push   %ebp
  801ac7:	89 e5                	mov    %esp,%ebp
  801ac9:	8b 4d 08             	mov    0x8(%ebp),%ecx
	int i;
	for (i = 0; i < NENV; i++)
  801acc:	b8 00 00 00 00       	mov    $0x0,%eax
		if (envs[i].env_type == type)
  801ad1:	6b d0 7c             	imul   $0x7c,%eax,%edx
  801ad4:	81 c2 00 00 c0 ee    	add    $0xeec00000,%edx
  801ada:	8b 52 50             	mov    0x50(%edx),%edx
  801add:	39 ca                	cmp    %ecx,%edx
  801adf:	75 0d                	jne    801aee <ipc_find_env+0x28>
			return envs[i].env_id;
  801ae1:	6b c0 7c             	imul   $0x7c,%eax,%eax
  801ae4:	05 00 00 c0 ee       	add    $0xeec00000,%eax
  801ae9:	8b 40 48             	mov    0x48(%eax),%eax
  801aec:	eb 0f                	jmp    801afd <ipc_find_env+0x37>
// Returns 0 if no such environment exists.
envid_t
ipc_find_env(enum EnvType type)
{
	int i;
	for (i = 0; i < NENV; i++)
  801aee:	83 c0 01             	add    $0x1,%eax
  801af1:	3d 00 04 00 00       	cmp    $0x400,%eax
  801af6:	75 d9                	jne    801ad1 <ipc_find_env+0xb>
		if (envs[i].env_type == type)
			return envs[i].env_id;
	return 0;
  801af8:	b8 00 00 00 00       	mov    $0x0,%eax
}
  801afd:	5d                   	pop    %ebp
  801afe:	c3                   	ret    

00801aff <pageref>:
#include <inc/lib.h>

int
pageref(void *v)
{
  801aff:	55                   	push   %ebp
  801b00:	89 e5                	mov    %esp,%ebp
  801b02:	8b 55 08             	mov    0x8(%ebp),%edx
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b05:	89 d0                	mov    %edx,%eax
  801b07:	c1 e8 16             	shr    $0x16,%eax
  801b0a:	8b 0c 85 00 d0 7b ef 	mov    -0x10843000(,%eax,4),%ecx
		return 0;
  801b11:	b8 00 00 00 00       	mov    $0x0,%eax
int
pageref(void *v)
{
	pte_t pte;

	if (!(uvpd[PDX(v)] & PTE_P))
  801b16:	f6 c1 01             	test   $0x1,%cl
  801b19:	74 1d                	je     801b38 <pageref+0x39>
		return 0;
	pte = uvpt[PGNUM(v)];
  801b1b:	c1 ea 0c             	shr    $0xc,%edx
  801b1e:	8b 14 95 00 00 40 ef 	mov    -0x10c00000(,%edx,4),%edx
	if (!(pte & PTE_P))
  801b25:	f6 c2 01             	test   $0x1,%dl
  801b28:	74 0e                	je     801b38 <pageref+0x39>
		return 0;
	return pages[PGNUM(pte)].pp_ref;
  801b2a:	c1 ea 0c             	shr    $0xc,%edx
  801b2d:	0f b7 04 d5 04 00 00 	movzwl -0x10fffffc(,%edx,8),%eax
  801b34:	ef 
  801b35:	0f b7 c0             	movzwl %ax,%eax
}
  801b38:	5d                   	pop    %ebp
  801b39:	c3                   	ret    
  801b3a:	66 90                	xchg   %ax,%ax
  801b3c:	66 90                	xchg   %ax,%ax
  801b3e:	66 90                	xchg   %ax,%ax

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
