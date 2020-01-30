CREATE PROCEDURE sp_List_Customer_ChannelWise(@CustomerCategory nVarchar(50), @CustomerType nVarchar(50), @ChannelType nvarchar(50),@FromDate DateTime, @ToDate DateTime)      
As      
SELECT @FromDate = dbo.StripDateFromTime(@FromDate), @ToDate = dbo.StripDateFromTime(@ToDate)
SELECT Customer.CustomerId, Company_Name, CASE QuotationAbstract.Active 
WHEN 1 THEN 
QuotationName
ELSE N'' END 
FROM QuotationAbstract LEFT JOIN QuotationCustomers ON QuotationCustomers.QuotationID = QuotationAbstract.QuotationID 
And QuotationAbstract.Active = 1 And ((QuotationAbstract.ValidFromDate  between @FromDate And @Todate or QuotationAbstract.ValidToDate between @FromDate And @Todate) or
(@FromDate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate or @Todate  between QuotationAbstract.ValidFromDate And QuotationAbstract.ValidToDate))
RIGHT JOIN Customer ON Customer.CustomerID = QuotationCustomers.CustomerID 
WHERE Cast(Customer.ChannelType As nVarchar) LIKE @ChannelType 
And Cast(CustomerCategory As nVarchar) Like @CustomerCategory
And Cast(Locality As nVarchar) Like @CustomerType
And Customer.Active = 1  





