using Microsoft.AspNetCore;
using Microsoft.AspNetCore.Hosting;
using System;
using System.Net.Http;

namespace RetailApi
{
    public class Program
    {
        public static void Main(string[] args)
        {
            CreateWebHostBuilder(args).Build().Run();
            //string baseAddress = "Http://http://localhost:3002/";
            //using (WebApp.Start<Startup>(url: baseAddress))
            //{
            //    // Create HttpClient and make a request to api/values 
            //    HttpClient client = new HttpClient();

            //    var response = client.GetAsync(baseAddress + "api/values").Result;

            //    Console.WriteLine(response);
            //    Console.WriteLine(response.Content.ReadAsStringAsync().Result);
            //    Console.ReadLine();
            //}

        }

        public static IWebHostBuilder CreateWebHostBuilder(string[] args) =>
            WebHost.CreateDefaultBuilder(args)
                .UseStartup<Startup>();
    }
}
