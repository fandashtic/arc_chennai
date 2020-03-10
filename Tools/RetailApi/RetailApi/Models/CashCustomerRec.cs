using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class CashCustomerRec
    {
        public int CustomerId { get; set; }
        public string CustomerName { get; set; }
        public string Address { get; set; }
        public DateTime? Dob { get; set; }
        public int? ReferredBy { get; set; }
        public string MembershipCode { get; set; }
        public string Telephone { get; set; }
        public string Fax { get; set; }
        public string ContactPerson { get; set; }
        public decimal? Discount { get; set; }
        public int? CategoryId { get; set; }
        public int? Flag { get; set; }
        public DateTime? CreationDate { get; set; }
        public DateTime? ModifiedDate { get; set; }
    }
}
