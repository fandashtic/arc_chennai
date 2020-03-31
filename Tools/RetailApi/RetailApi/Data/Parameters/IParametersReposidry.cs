using System;
using System.Collections.Generic;
using System.Linq;
using System.Threading.Tasks;
using RetailApi.Models;


namespace RetailApi.Data
{
    public interface IParametersReposidry
    {
        Task<List<KeyValue>> GetBeatList(int salesmanId = 0);
        Task<List<KeyValue>> GetSalesManList();
        Task<List<KeyValue>> GetCustomerList(int salesmanId = 0, int beatId = 0);
        Task<List<string>> GetVanList();
        Task<List<string>> GetVehicleTypes();
        Task<List<KeyValue>> GetItemsList();
        Task<string> GetQueryParams(string querry);

    }
}
