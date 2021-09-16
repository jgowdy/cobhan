using System;
using System.Runtime.InteropServices;
using System.Text;

namespace dotnetcore3
{
    internal static class Program
    {
        private delegate void ToUpperDelegate(byte[] input, int inputLen, byte[] output, int outputLen);

        static void Main(string[] args)
        {
            string arch;
            switch (RuntimeInformation.ProcessArchitecture)
            {
                case Architecture.Arm64:
                    arch = "arm64";
                    break;
                case Architecture.X64:
                    arch = "amd64";
                    break;
                default:
                    throw new Exception("Unsupported CPU");
            }

            string os,ext;
            if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
            {
                os = "windows";
                ext = "dll";
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
            {
                os = "linux";
                ext = "so";
            }
            else if (RuntimeInformation.IsOSPlatform(OSPlatform.OSX))
            {
                os = "macos";
                ext = "dylib";
            }
            else
            {
                throw new Exception("Unsupported OS");
            }

            var lib = NativeLibrary.Load($"../../../../output/{os}/{arch}/libplugtest.{ext}");

            var result = NativeLibrary.TryGetExport(lib, "toUpper", out var addr);
            if (!result)
                throw new Exception("Unable to locate toUpper function");

            var func = Marshal.GetDelegateForFunctionPointer<ToUpperDelegate>(addr);

            byte[] input = Encoding.UTF8.GetBytes("Initial value");

            var handle = GCHandle.Alloc(input, GCHandleType.Pinned);
            try
            {
                func(input, input.Length, input, input.Length);
            }
            finally
            {
                handle.Free();
            }

            Console.WriteLine(Encoding.UTF8.GetString(input));
        }
    }
}
