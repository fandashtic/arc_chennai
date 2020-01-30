
--spr_Brands_percall_detail 1, '6/6/2003', '12/12/2003' 
CREATE PROCEDURE spr_Brands_percall_detail(@SALESMANID INT,  
     @FROMDATE DATETIME,  
     @TODATE DATETIME)  
AS  
Declare @level int
Declare @BRAND As NVarchar(50)
Set @BRAND = dbo.LookupDictionaryItem(N'Brand',Default)
select @Level = HierarchyId from ItemHierarchy where HierarchyName like @BRAND

SELECT  InvoiceAbstract.invoicedate,   
 "Invoice Date" = InvoiceAbstract.invoicedate,   
 "Invoice ID" = VoucherPrefix.Prefix + CAST(InvoiceAbstract.DocumentID AS nvarchar),   
 "Doc Reference"=DocReference,  
 "Net Value (%c)" = Sum(Amount) ,  
 "Brands Per Call" = Count(Distinct (dbo.getBrandID(Product_Code, @Level)) )   
FROM InvoiceAbstract, Customer, Salesman, InvoiceDetail, VoucherPrefix  
WHERE   InvoiceType in (1, 3) AND InvoiceAbstract.InvoiceID=InvoiceDetail.InvoiceID AND  
 (InvoiceAbstract.Status & 128) = 0 AND  
 InvoiceAbstract.CustomerID = Customer.CustomerID AND  
 InvoiceAbstract.SalesmanID = Salesman.SalesmanID AND  
 Salesman.SalesmanID = @SALESMANID AND  
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND  
 VoucherPrefix.TranID = 'INVOICE'  
GROUP BY invoicedate, InvoiceAbstract.InvoiceID,InvoiceAbstract.DocReference,  
 InvoiceAbstract.DocumentID, VoucherPrefix.Prefix  

