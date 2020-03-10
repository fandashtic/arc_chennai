using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Manufacturer
    {
        public int ManufacturerId { get; set; }
        public string ManufacturerName { get; set; }
        public DateTime? CreationDate { get; set; }
        public int? Active { get; set; }
        public string Manufacturercode { get; set; }
    }
}
