using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class ItemCategories
    {
        public int CategoryId { get; set; }
        public string CategoryName { get; set; }
        public string Description { get; set; }
        public int? ParentId { get; set; }
        public int? TrackInventory { get; set; }
        public int? PriceOption { get; set; }
        public DateTime? CreationDate { get; set; }
        public int? Active { get; set; }
        public int? Level { get; set; }
        public DateTime? ModifiedDate { get; set; }
    }
}
