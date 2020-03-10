using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Groups
    {
        public string GroupName { get; set; }
        public string Permission { get; set; }
        public DateTime? CreationDate { get; set; }
    }
}
