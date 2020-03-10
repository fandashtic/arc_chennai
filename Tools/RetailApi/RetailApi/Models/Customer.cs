using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Customer
    {
        public string CustomerId { get; set; }
        public string CompanyName { get; set; }
        public string ContactPerson { get; set; }
        public int? CustomerCategory { get; set; }
        public string BillingAddress { get; set; }
        public string ShippingAddress { get; set; }
        public int? CityId { get; set; }
        public int? CountryId { get; set; }
        public int? AreaId { get; set; }
        public int? StateId { get; set; }
        public string Phone { get; set; }
        public string Email { get; set; }
        public DateTime? CreationDate { get; set; }
        public int? Active { get; set; }
        public decimal? Discount { get; set; }
        public string Dlnumber { get; set; }
        public string Tngst { get; set; }
        public int? CreditTerm { get; set; }
        public string Dlnumber21 { get; set; }
        public string Cst { get; set; }
        public decimal? CreditLimit { get; set; }
        public string AlternateCode { get; set; }
        public int? CreditRating { get; set; }
        public int? ChannelType { get; set; }
        public int? Locality { get; set; }
        public int? PaymentMode { get; set; }
        public int? AccountId { get; set; }
        public string CustomerPassword { get; set; }
        public int? District { get; set; }
        public int? TownClassify { get; set; }
        public int? AccountType { get; set; }
        public decimal? SequenceNo { get; set; }
        public string AlternateName { get; set; }
        public string TinNumber { get; set; }
        public string Potential { get; set; }
        public string Residence { get; set; }
        public string MobileNumber { get; set; }
        public string SubChannelId { get; set; }
        public int? TrackPoints { get; set; }
        public decimal? CollectedPoints { get; set; }
        public decimal? RedeemedPoints { get; set; }
        public string Pincode { get; set; }
        public int? SalutationId { get; set; }
        public string FirstName { get; set; }
        public string SecondName { get; set; }
        public string MembershipCode { get; set; }
        public int? RetailCategory { get; set; }
        public int? Occupation { get; set; }
        public string Fax { get; set; }
        public DateTime? Dob { get; set; }
        public string ReferredBy { get; set; }
        public string Awareness { get; set; }
        public DateTime? Modifieddate { get; set; }
        public int? TradeCategoryId { get; set; }
        public int? NoOfBillsOutstanding { get; set; }
        public int? SegmentId { get; set; }
        public decimal? AddCollDiscPercentage { get; set; }
        public int? DefaultBeatId { get; set; }
        public string RcsoutletId { get; set; }
        public int? ZoneId { get; set; }
        public int? Smsalert { get; set; }
        public string Pannumber { get; set; }
        public int? BillingStateId { get; set; }
        public int? ShippingStateId { get; set; }
        public string Gstin { get; set; }
        public int? IsRegistered { get; set; }
        public int? PreDefFlag { get; set; }
        public int? DnDflag { get; set; }
        public int Hhcustomer { get; set; }
        public string RecHhcustomerId { get; set; }
    }
}
