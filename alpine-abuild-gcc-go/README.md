# Alpine / musl support

Go's standard compiler 'gc' has two implicit dependencies on glibc specific behaviors that cause it to not work properly on Alpine with musl libc.

1) In violation of the ELF standard, glibc expects that libraries will be passed argc/argv when initialized.
2) Glibc deals with dlopen() of libraries with the Thread Local Storage model init-exec by reserving a limited amount of space, which works as long as you only dlopen() a limited number of libraries.  Go's standard compiler 'gc' only generates init-exec TLS, and doesn't have a compiler flag to compile with global-dynamic TLS.  Musl libc doesn't do the "reserve some space" hack, so it can't/won't dlopen() an ELF shared object with an init-exec TLS model.

In order to support Alpine/musl dlopen() of ELF shared objects written in Go, we need to do two things:

1) Use the gcc-go frontend, since gcc does know how to generate global-dynamic TLS.
2) Patch libgo so that it doesn't assume argc/argv in our shared libraries, causing a segfault.

## Todo

* The copy of APKBUILD should be converted into a patch applying our patch as patch 0042
* Figure out why we need to patch the page size detection and fix that also
* Upstream a fix for libgo to not crash when argc/argv aren't provided by the loader
