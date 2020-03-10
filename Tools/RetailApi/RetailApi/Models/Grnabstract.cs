using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Grnabstract
    {
        public int Grnid { get; set; }
        public int? BillId { get; set; }
        public DateTime Grndate { get; set; }
        public string VendorId { get; set; }
        public string Ponumber { get; set; }
        public DateTime? CreationTime { get; set; }
        public int? Grnstatus { get; set; }
        public int? DocumentId { get; set; }
        public string Ponumbers { get; set; }
        public int? NewBillId { get; set; }
        public int? OriginalGrn { get; set; }
        public int? ClientId { get; set; }
        public string DocRef { get; set; }
        public int? Grnidref { get; set; }
        public string DocumentIdref { get; set; }
        public string UserName { get; set; }
        public string Remarks { get; set; }
        public DateTime? CancelDate { get; set; }
        public int? RecdInvoiceId { get; set; }
        public string DocumentReference { get; set; }
        public string DocSerialType { get; set; }
        public string CancelUser { get; set; }
    }
}
