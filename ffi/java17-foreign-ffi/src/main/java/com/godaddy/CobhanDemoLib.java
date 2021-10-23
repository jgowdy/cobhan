package com.godaddy;

import static jdk.incubator.foreign.CLinker.C_INT;
import static jdk.incubator.foreign.CLinker.C_POINTER;

import java.nio.file.FileSystems;
import java.nio.file.Path;

import java.lang.invoke.MethodHandle;
import java.lang.invoke.MethodType;

import jdk.incubator.foreign.CLinker;
import jdk.incubator.foreign.FunctionDescriptor;
import jdk.incubator.foreign.MemoryAddress;
import jdk.incubator.foreign.SymbolLookup;
import jdk.incubator.foreign.MemorySegment;
import jdk.incubator.foreign.ResourceScope;

public class CobhanDemoLib {

    private final MethodHandle toUpperMethod;

    public CobhanDemoLib() {
        String os_path, ext, os_name = System.getProperty("os.name").toLowerCase();
        if(os_name.contains("linux")) {
            os_path = "linux";
            ext = "so";
        } else if(os_name.contains("mac")) {
            os_path = "macos";
            ext = "dylib";
        } else if(os_name.contains("win")) {
            os_path = "windows";
            ext = "dll";
        } else {
            throw new UnsupportedOperationException("Unsupported OS");
        }

        String arch_path, os_arch = System.getProperty("os.arch");
        if(os_arch.equals("x86_64") || os_arch.equals("amd64")) {
            arch_path = "amd64";
        } else if(os_arch.equals("aarch64") || os_arch.equals("arm64")) {
            arch_path = "arm64";
        } else {
            throw new UnsupportedOperationException("Unsupported CPU " + os_arch);
        }

        Path cwd = FileSystems.getDefault().getPath("").toAbsolutePath();
        Path libraryPath = cwd.getParent().resolve("output").resolve(os_path).resolve(arch_path);
        Path libraryFile = libraryPath.resolve("cobhan-demo-lib." + ext);

        System.load(libraryFile.toString());

        final var loader = SymbolLookup.loaderLookup();
        final var linker = CLinker.getInstance();

        toUpperMethod = linker.downcallHandle(
            loader.lookup("toUpper").get(),
            MethodType.methodType(int.class, MemoryAddress.class, int.class, MemoryAddress.class, int.class),
            FunctionDescriptor.of(C_INT, C_POINTER, C_INT, C_POINTER, C_INT)
        );
    }

    public String toUpper(String input) throws Exception {
        try (var scope = ResourceScope.newConfinedScope()) {
            var nullDelimitedMemorySegment = CLinker.toCString(input, scope);

            //Due to working with length delimited strings, we take a slice of the null delimited string
            var memorySlice = nullDelimitedMemorySegment.asSlice(0, nullDelimitedMemorySegment.byteSize() - 1);
            int result;
            try {
                result = (int)toUpperMethod.invokeExact(memorySlice.address(), (int)memorySlice.byteSize(),
                    memorySlice.address(), (int)memorySlice.byteSize());
            } catch (Throwable t) {
                throw new Exception("MethodHandle.invokeExact failed for toUpper", t);
            }

            if (result < 0) {
                throw new Exception("toUpper failed");
            }

            return CLinker.toJavaString(nullDelimitedMemorySegment);
        }
    }
}
