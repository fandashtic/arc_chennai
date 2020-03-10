using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using RetailApi.Data;
using RetailApi.Models;

namespace RetailApi.Controllers
{
    [Route("api/delivery")]
    [ApiController]
    public class DeliveryController : ControllerBase
    {
        readonly IDeliveryReposidry deliveryReposidry;

        public DeliveryController(IDeliveryReposidry _deliveryReposidry)
        {
            deliveryReposidry = _deliveryReposidry;
        }

        [HttpGet("[action]/{Van}")]
        public ActionResult<string> GerSalesInvoiceByDateAndVan(string Van, [FromQuery] DateTime Todate)
        {
            try
            {
                List<Parameters> parameters = new List<Parameters>();
                parameters.Add(new Parameters() { ParameterName = "TODATE", ParameterValue = Todate.ToString("dd-MMM-yyyy") });
                parameters.Add(new Parameters() { ParameterName = "Van", ParameterValue = Van });
                DataRepository reportDataRepository = new DataRepository();
                string str = reportDataRepository.GetData("Sp_arc_get_SalesFormDelivery", parameters);
                return str;
            }
            catch (Exception ex)
            {
                throw;
            }
        }

        [HttpGet("getvanlist")]
        public async Task<IActionResult> GetVanList()
        {
            try
            {
                var vans = await deliveryReposidry.GetVanList();
                if (vans == null)
                {
                    return NotFound();
                }

                return Ok(vans);
            }
            catch (Exception)
            {
                return BadRequest();
            }
        }
    }
}

