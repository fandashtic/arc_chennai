using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class FormatInfo
    {
        public int Id { get; set; }
        public int FormatId { get; set; }
        public int ColWidth { get; set; }
        public int ColAlignment { get; set; }
    }
}
