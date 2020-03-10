using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class CustomerSegment
    {
        public int SegmentId { get; set; }
        public string SegmentName { get; set; }
        public string Description { get; set; }
        public int? ParentId { get; set; }
        public int? Level { get; set; }
        public int? Active { get; set; }
        public DateTime? CreationDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public string SegmentCode { get; set; }
    }
}
