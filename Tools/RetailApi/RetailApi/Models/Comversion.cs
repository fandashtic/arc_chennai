using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Comversion
    {
        public string ComponentName { get; set; }
        public string Version { get; set; }
        public DateTime? CreationDate { get; set; }
        public int? InstallationId { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public int? Applicable { get; set; }
        public int? FileType { get; set; }
        public int? Recoverable { get; set; }
    }
}
