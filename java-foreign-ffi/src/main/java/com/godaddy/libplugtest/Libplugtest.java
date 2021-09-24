package com.godaddy.libplugtest;

import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystems;
import java.nio.file.Path;

import jdk.incubator.foreign.CLinker;

public class Libplugtest {
    private interface LibplugtestLibrary {
        int toUpper(byte[] input, int inputLen, byte[] output, int outputLen);
    }

    private LibplugtestLibrary libplugtest;

    public Libplugtest() {
        String os_path, ext;
        /*
        if(Platform.isLinux()) {
            os_path = "linux";
            ext = "so";
        } else if(Platform.isMac()) {
            os_path = "macos";
            ext = "dylib";
        } else if(Platform.isWindows()) {
            os_path = "windows";
            ext = "dll";
        } else {
            throw new UnsupportedOperationException("Unsupported OS");
        }
        */
        os_path = "linux";
        ext = "so";

        String arch_path;
        /*
        String os_arch = System.getProperty("os.arch");
        if(os_arch.equals("amd64")) {
            arch_path = "amd64";
        } else if(os_arch.equals("aarch64")) {
            arch_path = "arm64";
        } else {
            throw new UnsupportedOperationException("Unsupported CPU " + os_arch);
        }
        */
        arch_path = "amd64";

        Path cwd = FileSystems.getDefault().getPath("").toAbsolutePath();
        System.out.println("Current directory: " + cwd);

        Path libraryPath = cwd.getParent().resolve("output").resolve(os_path).resolve(arch_path);
        System.out.println("Library directory: " + libraryPath);

        Path libraryFile = libraryPath.resolve("libplugtest." + ext);

        System.out.println("Library: " + libraryFile);

        System.loadLibrary(libraryFile.toString());

        //libplugtest = (LibplugtestLibrary)Native.load(libraryFile.toString(), LibplugtestLibrary.class);
    }

    public String toUpper(String input) {
        String input_str = "Initial value";
        var bytes = input_str.getBytes(StandardCharsets.UTF_8);
        var result = libplugtest.toUpper(bytes, bytes.length, bytes, bytes.length);
        return new String(bytes, 0, result, StandardCharsets.UTF_8);
    }
}