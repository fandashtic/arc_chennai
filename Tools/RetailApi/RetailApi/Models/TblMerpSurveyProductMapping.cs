using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class TblMerpSurveyProductMapping
    {
        public int SurveyId { get; set; }
        public string ProductId { get; set; }
        public string ProductName { get; set; }
        public int ProductSequence { get; set; }
        public int? IsCompanyProduct { get; set; }
    }
}
