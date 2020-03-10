using System;
using System.Collections.Generic;

namespace RetailApi.Models
{
    public partial class Users
    {
        public string UserName { get; set; }
        public string Password { get; set; }
        public string GroupName { get; set; }
        public DateTime? CreationDate { get; set; }
        public int Active { get; set; }
    }
}
