using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class ProductCategorization
    {
        public int Id { get; set; }
        public string CategorizationName { get; set; }
        public DateTime CreationDate { get; set; }
    }
}
