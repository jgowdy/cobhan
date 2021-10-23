using System;
using System.Threading.Tasks;

namespace dotnetcore3
{
    internal static class Program
    {

        static async Task<int> Main(string[] args)
        {
            var cobhandemolib = new CobhanDemoLib();
            Console.WriteLine(cobhandemolib.toUpper("Initial value"));
            Console.WriteLine(cobhandemolib.AddDouble(1.1,1.2));

            await cobhandemolib.SleepTest(3);
            Console.WriteLine("Done sleeping");

            return 0;
        }
    }
}
