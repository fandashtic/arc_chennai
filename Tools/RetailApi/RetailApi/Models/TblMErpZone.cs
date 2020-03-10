using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class TblMErpZone
    {
        public int ZoneId { get; set; }
        public string ZoneName { get; set; }
        public DateTime? CreationDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public int? Active { get; set; }
    }
}
