using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Gstcomponent
    {
        public int GstcomponentCode { get; set; }
        public string GstcomponentDesc { get; set; }
        public DateTime CreationDate { get; set; }
    }
}
