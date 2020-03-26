using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace RetailApi.Models
{
    public partial class ReportDataModel : ReportData
    {
        public List<ReportDataModel> Nodes { get; set; }
    }
}
