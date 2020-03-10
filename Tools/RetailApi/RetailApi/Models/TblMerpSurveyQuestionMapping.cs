using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class TblMerpSurveyQuestionMapping
    {
        public int SurveyId { get; set; }
        public int QuestionId { get; set; }
        public string QuestionDesc { get; set; }
        public int? QuestionSequence { get; set; }
        public string QuestionType { get; set; }
        public int? QuestionLength { get; set; }
    }
}
