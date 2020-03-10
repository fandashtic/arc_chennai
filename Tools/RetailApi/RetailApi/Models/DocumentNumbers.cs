using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class DocumentNumbers
    {
        public int DocType { get; set; }
        public int? DocumentId { get; set; }
        public int? VoucherStart { get; set; }
    }
}
