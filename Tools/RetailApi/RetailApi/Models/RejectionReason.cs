using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class RejectionReason
    {
        public int MessageId { get; set; }
        public string Message { get; set; }
        public DateTime? CreationDate { get; set; }
        public int? Active { get; set; }
    }
}
