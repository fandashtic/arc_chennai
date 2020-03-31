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
    [Route("api/report")]
    [ApiController]
    public class ReportController : ControllerBase
    {
        readonly IReportReposidry reportReposidry;
       
        public ReportController(IReportReposidry _reportReposidry)
        {
            reportReposidry = _reportReposidry;            
        }

        [HttpGet("getallreports")]
        public async Task<IActionResult> GetAllReports()
        {
            try
            {
                List<ReportDataModel> reportDataModels = new List<ReportDataModel>();
                var allreports = await reportReposidry.GetAllReports();
                if (allreports == null)
                {
                    return NotFound();
                }
                else
                {
                    allreports.ToList().ForEach(report =>
                    {
                        reportDataModels.Add(new ReportDataModel()
                        {
                            Id = report.Id,
                            Node = report.Node,
                            Parent = report.Parent,
                            Parameters = report.Parameters,
                            ActionData = report.ActionData,
                            Action = report.Action,
                            DetailCommand = report.DetailCommand,
                            ForwardParam = report.ForwardParam,
                            Description = report.Description,
                            Inactive = report.Inactive
                        });
                    });

                    reportDataModels.Where(p => p.Parent == 0).ToList().ForEach(report =>
                    {
                        report = RecursiveNodes(report, reportDataModels);
                    });
                }

                return Ok(reportDataModels.Where(p => p.Parent == 0));
            }
            catch (Exception ex)
            {
                return BadRequest();
            }
        }

        [HttpGet("getreportsbyid/{reportId}")]
        public async Task<IActionResult> GetReportsById(int reportId)
        {
            try
            {
                List<ReportDataModel> reportDataModels = new List<ReportDataModel>();
                var reports = await reportReposidry.GetReportsById(reportId);
                if (reports == null)
                {
                    return NotFound();
                }
                return Ok(reports);
            }
            catch (Exception ex)
            {
                return BadRequest();
            }
        }

        [HttpPost("getreportsdata")]
        public async Task<IActionResult> GetReportsData(ReportsDataModel reportsDataModel)
        {
            try
            {
                DataRepository dataRepository = new DataRepository();
                string reports = await dataRepository.GetData(reportsDataModel.ProcedureName, GetValidParameters(reportsDataModel.Parameters));
                if (reports == null)
                {
                    return NotFound();
                }
                return Ok(reports);
            }
            catch (Exception ex)
            {
                return BadRequest();
            }
        }

        private List<Parameters> GetValidParameters(List<Parameters> parameters)
        {
            List<Parameters> _parameters = new List<Parameters>();
            try
            {
                parameters.ForEach(parameter =>
                {
                    if(IsValidQuery(parameter) != null)
                    {
                        _parameters.Add(parameter);
                    }
                });
            }
            catch (Exception)
            {
                throw;
            }
            return _parameters;
        }

        private ReportDataModel RecursiveNodes(ReportDataModel reportData, List<ReportDataModel> reportDataModels)
        {
            reportData.Nodes = reportDataModels.Where(p => p.Parent == reportData.Id).ToList();
            reportData.Nodes.ToList().ForEach(report =>
            {
                report = RecursiveNodes(report, reportDataModels);
            });
            return reportData;
        }

        private Parameters IsValidQuery(Parameters parameters)
        {
            if(parameters != null && !String.IsNullOrEmpty(parameters.AutoComplete))
            {
                if (parameters.AutoComplete.Contains("-1"))
                {
                    return null;
                }
                else
                {
                    return parameters;
                }
            }
            else
            {
                return parameters;
            }
        }
    }
}
