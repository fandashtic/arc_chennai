﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection.Metadata;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Mvc;
using RetailApi.Data;
using RetailApi.Models;

namespace RetailApi.Controllers
{
    [Route("api/parameters")]
    [ApiController]
    public class ParametersController : ControllerBase
    {
        readonly IParametersReposidry parametersReposidry;

        public ParametersController(IParametersReposidry _parametersReposidry)
        {
            parametersReposidry = _parametersReposidry;
        }

        [HttpGet("getparametersbyid/{paramId}")]
        public async Task<IActionResult> GetParametersById(int paramId)
        {
            try
            {
                DataRepository dataRepository = new DataRepository();
                return Ok(dataRepository.GetData("SELECT * FROM ParameterInfo WITH (NOLOCK) WHERE ParameterID = " + paramId.ToString() + " ORDER BY OrderBy ASC"));
            }
            catch (Exception)
            {
                return BadRequest();
            }
        }        

        [HttpGet("getvanlist")]
        public async Task<IActionResult> GetVanList()
        {
            try
            {
                var vans = await parametersReposidry.GetVanList();
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

        [HttpGet("getvehicletype")]
        public async Task<IActionResult> GetVehicleTypes()
        {
            try
            {
                var vehicleTypes = await parametersReposidry.GetVehicleTypes();
                if (vehicleTypes == null)
                {
                    return NotFound();
                }

                return Ok(vehicleTypes);
            }
            catch (Exception)
            {
                return BadRequest();
            }
        }

        [HttpGet("getsalesmanlist")]
        public async Task<IActionResult> GetSalesManList()
        {
            try
            {
                var salesmans = await parametersReposidry.GetSalesManList();
                if (salesmans == null)
                {
                    return NotFound();
                }

                return Ok(salesmans);
            }
            catch (Exception)
            {
                return BadRequest();
            }
        }

        [HttpGet("getbeatlist")]
        public async Task<IActionResult> GetBeatList([FromQuery] int salesmanId = 0)
        {
            try
            {
                var beats = await parametersReposidry.GetBeatList(salesmanId);
                if (beats == null)
                {
                    return NotFound();
                }

                return Ok(beats);
            }
            catch (Exception)
            {
                return BadRequest();
            }
        }

        [HttpGet("getcustomerlist")]
        public async Task<IActionResult> GetCustomerList([FromQuery] int salesmanId = 0, [FromQuery] int beatId = 0)
        {
            try
            {
                var customers = await parametersReposidry.GetCustomerList(salesmanId, beatId);
                if (customers == null)
                {
                    return NotFound();
                }

                return Ok(customers);
            }
            catch (Exception)
            {
                return BadRequest();
            }
        }

        [HttpGet("getitemslist")]
        public async Task<IActionResult> GetItemsList()
        {
            try
            {
                var customers = await parametersReposidry.GetItemsList();
                if (customers == null)
                {
                    return NotFound();
                }

                return Ok(customers);
            }
            catch (Exception)
            {
                return BadRequest();
            }
        }

        [HttpPost("getqueryparams")]
        public async Task<IActionResult> GetQueryParams(StringBodyModel stringBodyModel)
        {
            try
            {
                var querrys = await parametersReposidry.GetQueryParams(stringBodyModel.Data);
                if (querrys == null)
                {
                    return NotFound();
                }
                return Ok(querrys);
            }
            catch (Exception)
            {
                return BadRequest();
            }
        }
    }
}

