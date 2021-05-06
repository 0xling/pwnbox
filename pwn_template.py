from pwn import *
import time

context.log_level = 'debug'
context.arch = 'amd64'
context.terminal = ['tmux', 'splitw', '-h']

elf_path = './bank'
# p = process(elf_path, aslr = False, env={'LD_PRELOAD': './libc.so.6'})
# p = process(elf_path, env={'LD_PRELOAD': './libc.so.6'})
# p = process(elf_path, aslr=False)
# p = process(argv=['qemu-aarch64-static', '-g', '1234', '-cpu', 'max', '-L', '.', './chall'])
# p = process(argv=['qemu-aarch64-static', '-cpu', 'max', '-L', '.', './chall'])
# p = remote('8.140.179.11', 51322)
p = None

ru = lambda x: p.recvuntil(x)
sn = lambda x: p.send(x)
rl = lambda: p.recvline()
sl = lambda x: p.sendline(x)
rv = lambda x: p.recv(x)
sa = lambda a, b: p.sendafter(a, b)
sla = lambda a, b: p.sendlineafter(a, b)

elf = ELF(elf_path)
libc = ELF('/lib/x86_64-linux-gnu/libc.so.6')


def lg(s, addr=None):
    if addr:
        print('\033[1;31;40m[+]  %-15s  --> 0x%8x\033[0m' % (s, addr))
    else:
        print('\033[1;32;40m[-]  %-20s \033[0m' % (s))


def raddr(a=6):
    if a == 6:
        return u64(rv(a).ljust(8, '\x00'))
    else:
        return u64(rl().strip('\n').ljust(8, '\x00'))


def gdb_hint(cmd=None):
    gdb.attach(p, cmd)


def calc_leak(leak_value, func_name):
    libc.address = leak_value - libc.symbols[func_name]
    system_addr = libc.symbols['system']
    binsh_addr = next(libc.search('/bin/sh'))
    lg('system=%x, binsh=%x' % (system_addr, binsh_addr))


def exp():
    global p
    p = process(elf_path, aslr=False)
    #p = remote('81.70.195.166', 10000)
    gdb_hint()
    p.interactive()

exp()
