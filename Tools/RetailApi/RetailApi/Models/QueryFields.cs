using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class QueryFields
    {
        public int Id { get; set; }
        public int TableId { get; set; }
        public string FieldName { get; set; }
        public string DisplayName { get; set; }
        public int HasLookUp { get; set; }
        public string LookUpTable { get; set; }
        public string KeyField { get; set; }
        public string DisplayField { get; set; }
        public string Delimiter { get; set; }
    }
}
