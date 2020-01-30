CREATE PROCEDURE [dbo].[spr_list_invoices_by_beat_Van](@BEATID nVarChar(250),    
@VANs nVARCHAR(100),     --dummy parameter   
        @FROMDATE datetime,         
        @TODATE datetime)        
AS        
Declare @OTHERS As NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)

Declare @Pos Int
Declare @Beat nVarChar(100)
Declare @Van  nVarChar(100)
set @Pos = CharIndex(char(15), @BEATID)
Set @Beat = Convert(Int, SubString(@BEATID, 1, @Pos - 1))
set @Van = Substring(@BEATID, @Pos + 1, 251)
SELECT  InvoiceAbstract.InvoiceID, "InvoiceID" = Max(VoucherPrefix.Prefix + CAST(DocumentID AS nVARCHAR)),         
   "Doc Reference"=DocReference,        
   "Salesman" = IsNull(Salesman.Salesman_Name, @OTHERS), "Date" = InvoiceDate,         
   "Customer" = Customer.Company_Name,         
   "Quantity" = Sum(Quantity),      
   "KGS/Ltr" = sum(isnull(Quantity, 0) / Case isnull(Items.reportingunit, 1)     
           When 0 Then 1 Else isnull(Items.reportingunit, 1) End),
--Case When Max(Isnull(Items.ReportingUnit,0)) > 0 Then Cast(Cast((Sum(Quantity) / Max(IsNull(Items.ReportingUnit,1)))as Decimal(18,2)) as nvarchar) End,
--+ ' ' + Max(uom.[Description]) 
   "Net Value (%c)" = Sum(Amount),        
   "Balance (%c)" = Sum(Distinct Balance)
FROM InvoiceAbstract
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID 
Inner Join Customer On InvoiceAbstract.CustomerID = Customer.CustomerID 
Left Outer Join Beat On InvoiceAbstract.BeatID = Beat.BeatID 
Left Outer Join Salesman On InvoiceAbstract.SalesmanID = Salesman.SalesmanID
Inner Join VoucherPrefix On VoucherPrefix.TranID = 'INVOICE'        
Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code
Left Outer Join UOM On uom.uom = Items.ReportingUOM
Inner Join Van On InvoiceAbstract.VanNumber=Van.Van
WHERE   InvoiceType in (1, 3) AND        
   (Status & 128) = 0 AND        
  InvoiceAbstract.VanNumber= @VAN AND    
  InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND        
  InvoiceAbstract.BeatID = @Beat 
Group By InvoiceAbstract.InvoiceID,DocReference, Salesman.Salesman_Name,InvoiceDate,Customer.Company_Name      


