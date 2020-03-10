using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class TblMerpSurveyMaster
    {
        public int SurveyId { get; set; }
        public string SurveyCode { get; set; }
        public string SurveyDescription { get; set; }
        public string SurveyType { get; set; }
        public DateTime? EffectiveFrom { get; set; }
        public int? Active { get; set; }
        public int? Status { get; set; }
        public DateTime CreationDate { get; set; }
        public int Mandatory { get; set; }
    }
}
