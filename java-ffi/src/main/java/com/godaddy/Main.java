package com.godaddy;

import com.sun.jna.Library;
import com.sun.jna.Native;
import com.sun.jna.Platform;

import java.nio.charset.StandardCharsets;
import java.nio.file.FileSystems;
import java.nio.file.Path;

public class Main {
    public interface Libplugtest extends Library {
        void toUpper(byte[] input, int inputLen, byte[] output, int outputLen);
    }

    public static void main(String[] args) {
        String os_path, ext;
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

        String arch_path;
        String os_arch = System.getProperty("os.arch");
        if(os_arch.equals("x86_64")) {
            arch_path = "amd64";
        } else if(os_arch.equals("aarch64")) {
            arch_path = "arm64";
        } else {
            throw new UnsupportedOperationException("Unsupported CPU " + os_arch);
        }

        System.out.println(os_arch);
        Path path = FileSystems.getDefault().getPath("../output/"+os_path+"/"+arch_path).toAbsolutePath().resolve("libplugtest." + ext);
        var libplugtest = (Libplugtest)Native.loadLibrary(path.toString(), Libplugtest.class);
        String input_str = "Initial value";
        var bytes = input_str.getBytes(StandardCharsets.UTF_8);
        libplugtest.toUpper(bytes, bytes.length, bytes, bytes.length);
        System.out.println(new String(bytes, StandardCharsets.UTF_8));
    }
}
