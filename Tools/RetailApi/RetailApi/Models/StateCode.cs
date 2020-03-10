using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class StateCode
    {
        public int StateId { get; set; }
        public string ForumStateCode { get; set; }
        public string StateName { get; set; }
        public string CensusCode { get; set; }
        public DateTime CreationDate { get; set; }
    }
}
