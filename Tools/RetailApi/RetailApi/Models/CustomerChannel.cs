using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class CustomerChannel
    {
        public int ChannelType { get; set; }
        public string ChannelDesc { get; set; }
        public int? Active { get; set; }
        public string Code { get; set; }
        public int? PreDefFlag { get; set; }
    }
}
