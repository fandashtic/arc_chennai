--Exec ARC_Get_OrderVsInvoice '%', '01-Jan-2020', '04-Jan-2020'
IF EXISTS(SELECT * FROM sys.objects WHERE Name = N'ARC_Get_OrderVsInvoice')
BEGIN
    DROP PROC ARC_Get_OrderVsInvoice
END
GO
CREATE Proc ARC_Get_OrderVsInvoice(@CustomerName Nvarchar(255) = '%', @FromDate DateTime = '', @ToDate DateTime = '')  
AS BEGIN  
 DECLARE @CustomerId Nvarchar(255)  
 IF(ISNULL(@CustomerName, '') <> '%')  
 BEGIN  
  SELECT TOP 1 @CustomerId = CustomerId FROM Customer WITH (NOLOCK) WHERE Company_Name = @CustomerName  
 END  
 ELSE  
 BEGIN  
  SET @CustomerId =  '%'  
 END  
  
  
 Select  
  1,  
  --SA.SalesmanID,  
  S.Salesman_Name [Salesman],  
  --SA.BeatId,  
  B.Description [Beat],  
  SA.CustomerID,  
  C.Company_Name [Customer Name],  
  SA.SONumber [Order Number],  
  SA.SODate [Order Date],  
  SA.Value [Order Value],    
  IA.GSTFullDocID [InvoiceId], 
  IA.DocReference [Document id],
  IA.DocSerialType [Van Number],
  IA.InvoiceDate,  
  IA.NetValue [Invoice value]  
 from   
  SOAbstract SA WITH (NOLOCK)  
  FULL OUTER JOIN Salesman S WITH (NOLOCK) ON S.SalesmanID = SA.SalesmanID  
  FULL OUTER JOIN Beat B WITH (NOLOCK) ON B.BeatID = SA.BeatId  
  FULL OUTER JOIN Customer C WITH (NOLOCK) ON C.CustomerID = SA.CustomerID  
  FULL OUTER JOIN InvoiceAbstract IA WITH (NOLOCK) ON IA.CustomerID = SA.CustomerID AND IA.SONumber = SA.SONumber    
 WHERE SA.CustomerID = (CASE WHEN ISNUll(@CustomerId, '') <> '%' THEN @CustomerId ELSE SA.CustomerID END)  
 AND dbo.StripTimeFromDate(SODate) Between @FromDate AND @ToDate  
 Order By SA.SODate ASC  
END   
GO