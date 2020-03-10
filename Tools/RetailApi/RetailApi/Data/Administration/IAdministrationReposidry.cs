using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using RetailApi.Models;

namespace RetailApi.Data
{
    public interface IAdministrationReposidry
    {
        Task<List<Users>> GetUsers();
    }
}
