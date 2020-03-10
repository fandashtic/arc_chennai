using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class ReceivedSegments
    {
        public int SegmentId { get; set; }
        public string SegmentName { get; set; }
        public string Description { get; set; }
        public int? Level { get; set; }
        public int? Active { get; set; }
        public string BranchForumCode { get; set; }
        public int? Status { get; set; }
        public DateTime? CreationDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public string SegmentCode { get; set; }
        public string ParentCode { get; set; }
    }
}
