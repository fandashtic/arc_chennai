using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class ReportData
    {
        public int Id { get; set; }
        public string Node { get; set; }
        public int Action { get; set; }
        public string ActionData { get; set; }
        public string Description { get; set; }
        public int Parent { get; set; }
        public int? Parameters { get; set; }
        public int Image { get; set; }
        public int SelectedImage { get; set; }
        public int? FormatId { get; set; }
        public int? DetailCommand { get; set; }
        public int? KeyType { get; set; }
        public int Inactive { get; set; }
        public int? ForwardParam { get; set; }
        public int? PrintType { get; set; }
        public int? PrintWidth { get; set; }
        public int? GroupBy { get; set; }
        public string SubTotals { get; set; }
        public string SubTotalLabel { get; set; }
        public int? NoSubTotals { get; set; }
        public string ColumnWidth { get; set; }
        public string Header { get; set; }
        public string Footer { get; set; }
        public int? TopLineBreak { get; set; }
        public int? BottomLineBreak { get; set; }
        public int? PageLength { get; set; }
        public int? TopMargin { get; set; }
        public int? BottomMargin { get; set; }
    }
}
