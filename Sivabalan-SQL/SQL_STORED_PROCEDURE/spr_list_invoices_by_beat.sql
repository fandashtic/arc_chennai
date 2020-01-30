CREATE PROCEDURE spr_list_invoices_by_beat(@BEATID INT,      
        @FROMDATE datetime,       
        @TODATE datetime)      
AS      
Declare @OTHERS As NVarchar(50)  
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)  
  
SELECT  InvoiceAbstract.InvoiceID, "InvoiceID" = Case IsNull(InvoiceAbstract.GSTFlag,0) when 0 then VoucherPrefix.Prefix + CAST(DocumentID AS nVARCHAR) else ISNULL(InvoiceAbstract.GSTFullDocID,'') END,       
"Doc Reference"=DocReference,      
"Salesman" = IsNull(Salesman.Salesman_Name, @OTHERS), "Date" = InvoiceDate,       
"Customer" = Customer.Company_Name,       
"Quantity" = Sum(Quantity),    
"Reporting Unit" = Case When Count(DISTINCT Items.ReportingUOM) <=1 Then  
       Case When IsNull(Max(Items.ReportingUnit),0) > 0   
       Then Cast(Cast(Sum(Quantity)/Max(Items.ReportingUnit) as Decimal(18,2)) as nVarchar) + ' ' + Max(uom.[Description]) End  
       End,     
"Net Value (%c)" = NetValue,      
"Balance (%c)" = Balance    
FROM InvoiceAbstract
Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID 
Left Outer Join  Salesman On InvoiceAbstract.SalesmanID = Salesman.SalesmanID 
Inner Join VoucherPrefix On VoucherPrefix.TranID = 'INVOICE'  
Inner Join  InvoiceDetail  On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
Inner Join  Items   On InvoiceDetail.Product_Code = Items.Product_Code
Left Outer Join  UOM On uom.uom = Items.ReportingUOM
WHERE   InvoiceType in (1, 3) AND    
(Status & 128) = 0 AND    
InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND    
InvoiceAbstract.BeatID = @BeatID 
Group By InvoiceAbstract.InvoiceID, InvoiceAbstract.DocumentID,   
InvoiceAbstract.DocReference, Salesman.Salesman_Name, InvoiceAbstract.InvoiceDate,  
Customer.Company_Name, InvoiceAbstract.NetValue, InvoiceAbstract.Balance,InvoiceAbstract.GSTFlag,InvoiceAbstract.GSTFullDocID,   
VoucherPrefix.Prefix  
