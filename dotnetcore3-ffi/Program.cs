using System;
using System.Runtime.InteropServices;
using System.Text;

namespace dotnetcore3
{
    internal static class Program
    {

        static void Main(string[] args)
        {
            var libplugtest = new Libplugtest();
            Console.WriteLine(libplugtest.toUpper("Initial value"));
        }
    }
}
