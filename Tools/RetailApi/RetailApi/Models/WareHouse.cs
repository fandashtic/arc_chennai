using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class WareHouse
    {
        public string WareHouseId { get; set; }
        public string WareHouseName { get; set; }
        public string Address { get; set; }
        public int City { get; set; }
        public int State { get; set; }
        public int Country { get; set; }
        public string ForumId { get; set; }
        public int Active { get; set; }
        public int? AccountId { get; set; }
        public string TinNumber { get; set; }
        public int? StateInfo { get; set; }
        public int? BillingStateId { get; set; }
        public string Gstin { get; set; }
        public int? IsRegistered { get; set; }
    }
}
