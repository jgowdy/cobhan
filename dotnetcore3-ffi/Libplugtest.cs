using System;
using System.IO;
using System.Runtime.InteropServices;
using System.Text;

public class Libplugtest 
{
    private delegate double AddDoubleDelegate(double x, double y);
    private delegate Int64 AddInt64Delegate(Int64 x, Int64 y);
    private delegate Int32 AddInt32Delegate(Int32 x, Int32 y);
    private delegate void SleepTestDelegate(Int32 seconds);
    private delegate Int32 CalculatePiDelegate(Int32 digits, IntPtr output, Int32 outputCapacity);
    private delegate int ToUpperDelegate(IntPtr input, Int32 inputLen, IntPtr output, Int32 outputCapacity);

    private static AddInt32Delegate addInt32Delegate;
    private static AddInt64Delegate addInt64Delegate;   
    private static AddDoubleDelegate addDoubleDelegate;
    private static SleepTestDelegate sleepTestDelegate;
    private static CalculatePiDelegate calculatePiDelegate;
    private static ToUpperDelegate toUpperDelegate;
    private static IntPtr hLibrary = IntPtr.Zero;

    static Libplugtest()
    {
        string os,ext;
        bool needsChdir = false;

        if (RuntimeInformation.IsOSPlatform(OSPlatform.Windows))
        {
            os = "windows";
            ext = "dll";
        }
        else if (RuntimeInformation.IsOSPlatform(OSPlatform.Linux))
        {
            if(Directory.GetFiles("/lib", "libc.musl*").Length > 0)
            {
                needsChdir = true;
            }
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

        string libraryBasePath = "../output/";
        string libraryPath = Path.GetFullPath(Path.Join(libraryBasePath, os, arch));

        string oldDir = string.Empty;
        if(needsChdir)
        {
            oldDir = Directory.GetCurrentDirectory();
            Directory.SetCurrentDirectory(libraryPath);
        }
        
        hLibrary = NativeLibrary.Load(Path.Join(libraryPath, $"libplugtest.{ext}"));

        if(needsChdir)
        {
            Directory.SetCurrentDirectory(oldDir);
        }

        IntPtr addr;
        
        addr = NativeLibrary.GetExport(hLibrary, "toUpper");
        toUpperDelegate = Marshal.GetDelegateForFunctionPointer<ToUpperDelegate>(addr);
        addr = NativeLibrary.GetExport(hLibrary, "addDouble");
        addDoubleDelegate = Marshal.GetDelegateForFunctionPointer<AddDoubleDelegate>(addr);
        addr = NativeLibrary.GetExport(hLibrary, "addInt32");
        addInt32Delegate = Marshal.GetDelegateForFunctionPointer<AddInt32Delegate>(addr);
        addr = NativeLibrary.GetExport(hLibrary, "addInt64");
        addInt64Delegate = Marshal.GetDelegateForFunctionPointer<AddInt64Delegate>(addr);
        addr = NativeLibrary.GetExport(hLibrary, "sleepTest");
        sleepTestDelegate = Marshal.GetDelegateForFunctionPointer<SleepTestDelegate>(addr);
        addr = NativeLibrary.GetExport(hLibrary, "calculatePi");
        calculatePiDelegate = Marshal.GetDelegateForFunctionPointer<CalculatePiDelegate>(addr);
    }

    public string toUpper(string input)
    {
        var inputBytes = Encoding.UTF8.GetBytes(input);

        var handle = GCHandle.Alloc(inputBytes, GCHandleType.Pinned);
        var result = 0;
        try
        {
            result = toUpperDelegate(handle.AddrOfPinnedObject(), inputBytes.Length, handle.AddrOfPinnedObject(), inputBytes.Length);
        }
        finally
        {
            handle.Free();
        }

        if (result < 0)
            throw new Exception("toUpper failed");

        return Encoding.UTF8.GetString(inputBytes, 0, result);
    }

    public double AddDouble(double x, double y)
    {
        return addDoubleDelegate(x, y);
    }

    public long AddInt64(long x, long y)
    {
        return addInt64Delegate(x, y); 
    }

    public int AddInt32(int x, int y)
    {
        return addInt32Delegate(x, y);
    }

    public void SleepTest(int seconds)
    {
        sleepTestDelegate(seconds);
    }

    public string CalculatePi(int digits)
    {
        var outputBytes = new byte[digits+1];
        var handle = GCHandle.Alloc(outputBytes, GCHandleType.Pinned);
        var result = 0;
        try 
        {
            result = calculatePiDelegate(digits, handle.AddrOfPinnedObject(), outputBytes.Length);
        }
        finally
        {
            handle.Free();
        }

        if (result < 0)
            throw new Exception("calculatePi failed");

        return Encoding.UTF8.GetString(outputBytes, 0, result);
    }
}