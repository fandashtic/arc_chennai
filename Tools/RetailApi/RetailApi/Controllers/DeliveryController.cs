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

        [HttpGet("gersalesinvoicebydateandvan/{van?}")]
        public async Task<ActionResult<string>> GerSalesInvoiceByDateAndVanAsync(string van, [FromQuery] DateTime Todate)
        {
            try
            {
                DataRepository dataRepository = new DataRepository();
                List<Parameters> parameters = new List<Parameters>();
                parameters.Add(new Parameters() { ParameterName = "TODATE", ParameterValue = Todate.ToString("dd-MMM-yyyy") });
                parameters.Add(new Parameters() { ParameterName = "Van", ParameterValue = DataUtility.ParamValue(van) });
                DataRepository reportDataRepository = new DataRepository();
                string str = await dataRepository.GetData("Sp_arc_get_SalesFormDelivery", parameters);
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

        [HttpPost("updatedelivery")]
        public IActionResult UpdateDelivery(UpdateDeliveryData deliveryData)
        {
            try
            {
                //List<Parameters> parameters = new List<Parameters>();
                //parameters.Add(new Parameters() { ParameterName = "TODATE", ParameterValue = Todate.ToString("dd-MMM-yyyy") });
                //parameters.Add(new Parameters() { ParameterName = "Van", ParameterValue = DataUtility.ParamValue(Van) });
                //DataRepository reportDataRepository = new DataRepository();
                //string str = reportDataRepository.GetData("Sp_arc_get_SalesFormDelivery", parameters);
                return Ok();
            }
            catch (Exception ex)
            {
                throw;
            }
        }
    }
}

