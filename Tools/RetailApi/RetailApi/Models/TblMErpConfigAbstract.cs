using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class TblMErpConfigAbstract
    {
        public string ScreenCode { get; set; }
        public string ScreenName { get; set; }
        public string Description { get; set; }
        public int? Flag { get; set; }
        public DateTime? CreationDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
    }
}
