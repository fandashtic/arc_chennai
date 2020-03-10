using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Salesman
    {
        public int SalesmanId { get; set; }
        public string SalesmanName { get; set; }
        public string Address { get; set; }
        public DateTime? CreationDate { get; set; }
        public int? Active { get; set; }
        public string ResidentialNumber { get; set; }
        public string MobileNumber { get; set; }
        public decimal? Commission { get; set; }
        public string SalesManCode { get; set; }
        public int? CategoryMapping { get; set; }
        public DateTime? ModifiedDate { get; set; }
        public int? SkillLevel { get; set; }
        public int Smsalert { get; set; }
        public int? SalesmanCategoryId { get; set; }
    }
}
