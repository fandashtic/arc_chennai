using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Vendors
    {
        public string VendorId { get; set; }
        public string VendorName { get; set; }
        public string ContactPerson { get; set; }
        public string Address { get; set; }
        public int? CityId { get; set; }
        public int? StateId { get; set; }
        public int? CountryId { get; set; }
        public int? Zip { get; set; }
        public string Fax { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public DateTime? CreationDate { get; set; }
        public int? Active { get; set; }
        public string AlternateCode { get; set; }
        public int? Locality { get; set; }
        public string ProductSupplied { get; set; }
        public string VendorRating { get; set; }
        public int? SaleId { get; set; }
        public string Tngst { get; set; }
        public string Cst { get; set; }
        public string PayableTo { get; set; }
        public int? CreditTerm { get; set; }
        public int? AccountId { get; set; }
        public string TinNumber { get; set; }
        public string Pannumber { get; set; }
        public int? BillingStateId { get; set; }
        public string Gstin { get; set; }
        public int? IsRegistered { get; set; }
    }
}
