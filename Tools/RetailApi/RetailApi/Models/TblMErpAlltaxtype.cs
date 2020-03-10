using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class TblMErpAlltaxtype
    {
        public int TaxId { get; set; }
        public string Taxtype { get; set; }
        public DateTime? CreationDate { get; set; }
    }
}
