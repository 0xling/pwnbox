import os
import hashlib
import argparse

libs_dir = '/ctf/tool/glibc-all-in-one/libs'


def get_libc_ld(dir):
    libc = None
    ld = None
    for filename in os.listdir(dir):
        if filename.startswith('libc-') & (not filename.endswith('i64')) & (not filename.endswith('idb')):
            libc = os.path.join(dir, filename)
        if filename.startswith('ld-') & (not filename.endswith('i64')) & (not filename.endswith('idb')):
            ld = os.path.join(dir, filename)
        if (libc is not None) & (ld is not None):
            return libc, ld

    if not libc:
        raise Exception('not find libc from %s' % dir)
    if not ld:
        raise Exception('not find ld from %s' % dir)


def patch_elf(dir, binary):
    libc, ld = get_libc_ld(dir)

    if not os.path.exists('%s.bak' % binary):
        command = 'cp %s %s.bak' % (binary, binary)
        os.system(command)

    command = 'patchelf --set-interpreter %s %s' % (ld, binary)
    os.system(command)

    command = 'patchelf --replace-needed libc.so.6 %s %s' % (libc, binary)
    os.system(command)

    print('patch %s finish' % binary)
    os.system('ldd %s' % binary)


def md5(fname):
    hash_md5 = hashlib.md5()
    with open(fname, "rb") as f:
        for chunk in iter(lambda: f.read(4096), b""):
            hash_md5.update(chunk)
    return hash_md5.hexdigest()


def generate_hash():
    fp = open(os.path.join(libs_dir, 'hash'), 'w')
    for subdir in os.listdir(libs_dir):
        subdir = os.path.join(libs_dir, subdir)
        if os.path.isdir(subdir):
            # print(subdir)
            libc, ld = get_libc_ld(subdir)
            libc_s = md5(libc)
            ld_s = md5(ld)
            fp.write('%s:%s\n' % (libc_s, libc))
            fp.write('%s:%s\n' % (ld_s, ld))
    fp.close()


def find_dir(libc):
    libc_md5 = md5(libc)
    print('libc hash=%s' % libc_md5)
    if not os.path.exists(os.path.join(libs_dir, 'hash')):
        generate_hash()
    with open(os.path.join(libs_dir, 'hash'), 'rb') as f:
        for line in f:
            line = line.strip()
            hash = line.split(b':')[0]
            if hash == libc_md5:
                lib = line.split(b':')[1]
                dir = lib[:lib.rfind('/')]
                return dir
    return None


def main():
    parser = argparse.ArgumentParser('python mypatchelf.py')
    parser.add_argument('-b', required=True, help='the binary to be patched')
    parser.add_argument('-d', help='the directory of libc/ld')
    parser.add_argument('-l', help='the library of libc')

    args = parser.parse_args()

    binary = args.b
    dir = args.d
    libc = args.l

    if (dir is None) & (libc is None):
        parser.print_help()
        exit(0)

    if dir is None:
        dir = find_dir(libc)

    if dir is None:
        print('not find dir for %s' % libc)
        exit(0)

    patch_elf(dir, binary)


if __name__ == '__main__':
    main()
