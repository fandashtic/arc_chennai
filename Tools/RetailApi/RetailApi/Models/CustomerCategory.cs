using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class CustomerCategory
    {
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
        public int Active { get; set; }
        public DateTime? CreationDate { get; set; }
    }
}
