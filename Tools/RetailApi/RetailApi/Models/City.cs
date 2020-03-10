using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class City
    {
        public int CityId { get; set; }
        public string CityName { get; set; }
        public int Active { get; set; }
        public int? DistrictId { get; set; }
        public int? StateId { get; set; }
        public string Stdcode { get; set; }
        public int? PreDefFlag { get; set; }
    }
}
