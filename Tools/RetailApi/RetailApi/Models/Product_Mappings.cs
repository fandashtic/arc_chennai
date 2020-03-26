using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace RetailApi.Models
{
    public class Product_Mappings
    {
        public string Product_Code { get; set; }
        public string ProductName { get; set; }
        public int? CategoryGroup { get; set; }
        public int? Category { get; set; }
        public int? ItemFamily { get; set; }
        public int? ItemSubFamily { get; set; }
        public int? ItemGroup { get; set; }
    }
}
