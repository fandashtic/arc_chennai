using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;

namespace RetailApi.Models
{
    public class UpdateDeliveryData
    {
        public DateTime DateOfDelivery { get; set; }
        public List<string> InvoiceIds { get; set; }
    }
}
