using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Brand
    {
        public int BrandId { get; set; }
        public string BrandName { get; set; }
        public DateTime? CreationDate { get; set; }
        public string ManufacturerId { get; set; }
        public int? Active { get; set; }
    }
}
