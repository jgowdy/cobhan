
This patch patches the libgo library of the gcc-go frontend to work with musl libc, since musl's loader doesn't pass argc/argv to libraries the way glibc does (in violation of the ELF standard)

TODO: The copy of APKBUILD should be converted into a patch applying our patch as patch 0042
