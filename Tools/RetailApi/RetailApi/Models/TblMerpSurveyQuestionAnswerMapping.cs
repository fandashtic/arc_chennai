using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class TblMerpSurveyQuestionAnswerMapping
    {
        public int SurveyId { get; set; }
        public int QuestionId { get; set; }
        public int AnswerId { get; set; }
        public string AnswerDesc { get; set; }
        public int? AnswerSequence { get; set; }
        public string AnswerValue { get; set; }
    }
}
