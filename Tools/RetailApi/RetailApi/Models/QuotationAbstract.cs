using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class QuotationAbstract
    {
        public int QuotationId { get; set; }
        public int? DocumentId { get; set; }
        public string QuotationName { get; set; }
        public DateTime? QuotationDate { get; set; }
        public DateTime? CreationDate { get; set; }
        public string UserName { get; set; }
        public DateTime? ValidFromDate { get; set; }
        public DateTime? ValidToDate { get; set; }
        public int? AllowInvoiceScheme { get; set; }
        public int? QuotationType { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public int? Active { get; set; }
        public string Prefix { get; set; }
        public int? QuotationSubType { get; set; }
        public int? QuotationLevel { get; set; }
        public int? Uomconversion { get; set; }
        public int SpecialTax { get; set; }
        public string ModifiedUser { get; set; }
        public int? Gstflag { get; set; }
    }
}
