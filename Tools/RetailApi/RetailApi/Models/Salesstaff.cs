using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Salesstaff
    {
        public string StaffName { get; set; }
        public string Address { get; set; }
        public string Phone { get; set; }
        public decimal? Commission { get; set; }
        public int? Active { get; set; }
        public int StaffId { get; set; }
    }
}
