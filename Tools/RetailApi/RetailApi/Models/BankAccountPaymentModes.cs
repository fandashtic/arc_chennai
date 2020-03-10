using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class BankAccountPaymentModes
    {
        public int BankId { get; set; }
        public int CreditCardId { get; set; }
        public decimal? ServiceChargePercentage { get; set; }
    }
}
