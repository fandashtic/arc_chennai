using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class TaxStateType
    {
        public int TaxStateTypeId { get; set; }
        public string TaxStateTypeName { get; set; }
        public DateTime CreationDate { get; set; }
    }
}
