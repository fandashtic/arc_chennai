using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class AccountsMaster
    {
        public int AccountId { get; set; }
        public string AccountName { get; set; }
        public int GroupId { get; set; }
        public int Active { get; set; }
        public int Fixed { get; set; }
        public double? OpeningBalance { get; set; }
        public double? AdditionalField1 { get; set; }
        public double? AdditionalField2 { get; set; }
        public double? AdditionalField3 { get; set; }
        public DateTime? AdditionalField4 { get; set; }
        public DateTime? AdditionalField5 { get; set; }
        public string AdditionalField6 { get; set; }
        public string AdditionalField7 { get; set; }
        public string AdditionalField8 { get; set; }
        public string AdditionalField9 { get; set; }
        public string AdditionalField10 { get; set; }
        public string AdditionalField11 { get; set; }
        public string AdditionalField12 { get; set; }
        public string AdditionalField13 { get; set; }
        public string AdditionalField14 { get; set; }
        public DateTime? CreationDate { get; set; }
        public DateTime? LastModifiedDate { get; set; }
        public DateTime? AdditionalField15 { get; set; }
        public DateTime? AdditionalField16 { get; set; }
        public DateTime? AdditionalField17 { get; set; }
        public string UserName { get; set; }
        public int? RetailPaymentMode { get; set; }
        public int? AdditionalField18 { get; set; }
        public int? OrgType { get; set; }
        public int? DefaultGroupId { get; set; }
    }
}
