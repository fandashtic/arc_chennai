using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Properties
    {
        public int PropertyId { get; set; }
        public string PropertyName { get; set; }
        public DateTime? CreationDate { get; set; }
    }
}
