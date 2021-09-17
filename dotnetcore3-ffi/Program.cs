using System;
using System.Threading.Tasks;

namespace dotnetcore3
{
    internal static class Program
    {

        static async Task<int> Main(string[] args)
        {
            var libplugtest = new Libplugtest();
            Console.WriteLine(libplugtest.toUpper("Initial value"));
            Console.WriteLine(libplugtest.AddDouble(1.1,1.2));

            await libplugtest.SleepTest(3);
            Console.WriteLine("Done sleeping");

            return 0;
        }
    }
}
