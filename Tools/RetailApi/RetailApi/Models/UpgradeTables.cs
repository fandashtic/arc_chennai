using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class UpgradeTables
    {
        public int TableId { get; set; }
        public string TableName { get; set; }
        public string UpgradeCriteria { get; set; }
    }
}
