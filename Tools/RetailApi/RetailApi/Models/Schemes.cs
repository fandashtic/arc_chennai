using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Schemes
    {
        public int SchemeId { get; set; }
        public string SchemeName { get; set; }
        public int? SchemeType { get; set; }
        public DateTime? ValidFrom { get; set; }
        public DateTime? ValidTo { get; set; }
        public int? Promptonly { get; set; }
        public string Message { get; set; }
        public int? Active { get; set; }
        public string SchemeDescription { get; set; }
        public int? SecondaryScheme { get; set; }
        public int? HasSlabs { get; set; }
        public DateTime? CreationDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public int? Approved { get; set; }
        public decimal? BudgetedAmount { get; set; }
        public int? Customer { get; set; }
        public int? HappyScheme { get; set; }
        public DateTime? FromHour { get; set; }
        public DateTime? ToHour { get; set; }
        public int? FromWeekDay { get; set; }
        public int? ToWeekDay { get; set; }
        public int? FromDayMonth { get; set; }
        public int? ToDayMonth { get; set; }
        public string PaymentMode { get; set; }
        public int? ApplyOn { get; set; }
    }
}
