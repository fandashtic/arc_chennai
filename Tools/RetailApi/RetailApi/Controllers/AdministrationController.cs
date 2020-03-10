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
    [Route("api/administration")]
    [ApiController]
    public class AdministrationController : ControllerBase
    {        
        readonly IAdministrationReposidry administrationReposidry;

        public AdministrationController(IAdministrationReposidry _administrationReposidry)
        {            
            administrationReposidry = _administrationReposidry;
        }

        [HttpGet("getusers")]
        public async Task<IActionResult> GerUsers()
        {
            try
            {
                var users = await administrationReposidry.GetUsers();
                if (users == null)
                {
                    return NotFound();
                }

                return Ok(users);
            }
            catch (Exception)
            {
                return BadRequest();
            }
        }
    }
}