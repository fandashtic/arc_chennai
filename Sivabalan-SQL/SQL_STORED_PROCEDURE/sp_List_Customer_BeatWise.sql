CREATE PROCEDURE sp_List_Customer_BeatWise(@CustomerCategory nVarchar(50), @CustomerType nVarchar(50), @BeatID nVarchar(50), @FromDate DateTime, @ToDate DateTime)  
As        
SELECT @FromDate = dbo.StripDateFromTime(@FromDate), @ToDate = dbo.StripDateFromTime(@ToDate)  
SELECT 
 Distinct Customer.CustomerId, Company_Name, CASE QuotationAbstract.Active   
WHEN 1 THEN   
QuotationName  
ELSE   
N''   
END   
FROM QuotationAbstract LEFT JOIN QuotationCustomers ON QuotationCustomers.QuotationID = QuotationAbstract.QuotationID   
And QuotationAbstract.Active = 1 And ((QuotationAbstract.ValidFromDate  between @FromDate And @Todate or QuotationAbstract.ValidToDate between @FromDate And @Todate) or  
(@FromDate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate or @Todate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate))  
RIGHT JOIN Customer ON Customer.CustomerID = QuotationCustomers.CustomerID   
INNER JOIN Beat_SalesMan ON Beat_SalesMan.CustomerID = Customer.CustomerID  
WHERE Cast(Beat_SalesMan.BeatID As nVarchar) LIKE @BeatID       
And Cast(CustomerCategory As nVarchar) Like @CustomerCategory  
And Cast(Locality As nVarchar) Like @CustomerType  
And Customer.Active = 1    
  
  
  
  
  


