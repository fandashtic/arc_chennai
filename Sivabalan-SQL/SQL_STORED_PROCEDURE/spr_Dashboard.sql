CREATE PROCEDURE spr_Dashboard(@CompanyID nVarchar(100), @FromDate DateTime, @ToDate DateTime)  
AS  
SELECT CustomerID, CustomerID, Company_Name, ReportDate,
"Check List" = IsNull((SELECT TOP 1 CASE Rep.ReportName WHEN 'Check List' THEN 'Yes' ELSE 'No' END FROM Reports Rep WHERE 
Rep.CompanyID = Reports.CompanyID And Rep.ReportDate = Reports.ReportDate And Rep.ReportName = 'Check List'),'No'), 
"SI-34" = IsNull((SELECT TOP 1 CASE Rep.ReportName WHEN 'SI-34' THEN 'Yes' ELSE 'No' END FROM Reports Rep WHERE 
Rep.CompanyID = Reports.CompanyID And Rep.ReportDate = Reports.ReportDate And Rep.ReportName = 'SI-34'),'No'), 
"Finance" = IsNull((SELECT TOP 1 CASE Rep.ReportName WHEN 'Finance' THEN 'Yes' ELSE 'No' END FROM Reports Rep WHERE 
Rep.CompanyID = Reports.CompanyID And Rep.ReportDate = Reports.ReportDate And Rep.ReportName = 'Finance'),'No'),
"Claim Settlement" = IsNull((SELECT TOP 1 CASE Rep.ReportName WHEN 'Claim Settlement' THEN 'Yes' ELSE 'No' END FROM Reports Rep WHERE 
Rep.CompanyID = Reports.CompanyID And Rep.ReportDate = Reports.ReportDate And Rep.ReportName = 'Claim Settlement'),'No'), 
"SI-24" = IsNull((SELECT TOP 1 CASE Rep.ReportName WHEN 'SI-24' THEN 'Yes' ELSE 'No' END FROM Reports Rep WHERE 
Rep.CompanyID = Reports.CompanyID and Rep.ReportDate = Reports.ReportDate And Rep.ReportName = 'SI-24'),'No'), 
"SKUwise Schemes & Damages" = IsNull((SELECT TOP 1 CASE Rep.ReportName WHEN 'SKUwise Schemes & Damages' THEN 'Yes' ELSE 'No' END FROM Reports Rep WHERE 
Rep.CompanyID = Reports.CompanyID And Rep.ReportDate = Reports.ReportDate And Rep.ReportName = 'SKUwise Schemes & Damages'),'No') FROM Reports, Customer
WHERE Customer.AlterNateCode =  Reports.CompanyID And
Customer.CustomerID Like @CompanyID And ReportDate BETWEEN @FromDate AND @ToDate
GROUP BY Reports.CompanyID, CustomerID, Company_Name, ReportDate





