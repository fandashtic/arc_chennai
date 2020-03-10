using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class AccountGroup
    {
        public int GroupId { get; set; }
        public string GroupName { get; set; }
        public int AccountType { get; set; }
        public int? ParentGroup { get; set; }
        public int Active { get; set; }
        public int? Fixed { get; set; }
        public DateTime? CreationDate { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public int? OrgType { get; set; }
    }
}
