using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class TblMerpSurveyChannelMapping
    {
        public int SurveyId { get; set; }
        public string ChannelType { get; set; }
        public string OutletType { get; set; }
        public string LoyaltyProgram { get; set; }
    }
}
