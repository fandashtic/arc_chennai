--exec [spr_list_invoices_MUOM_Top_New] @FROMDATE ='04-Jan-2020', @TODATE='04-Jan-2020',@DocType='%'    
CREATE procedure [dbo].[spr_list_invoices_MUOM_Top_New]    
(     
@FROMDATE datetime,    
@TODATE datetime,    
@DocType nvarchar(100),    
@Term Nvarchar(255) = '%')     
AS                     
Begin DECLARE @INV AS NVARCHAR(50)                     
DECLARE @CASH AS NVARCHAR(50)         
DECLARE @CREDIT AS NVARCHAR(50)                     
DECLARE @CHEQUE AS NVARCHAR(50)         
DECLARE @DD AS NVARCHAR(50)         
SELECT @CASH = DBO.LookUpDictionaryItem(N'Cash',default)         
SELECT @CREDIT = DBO.LookUpDictionaryItem(N'Credit',default)           
SELECT @CHEQUE = DBO.LookUpDictionaryItem(N'Cheque',default)         
SELECT @DD = DBO.LookUpDictionaryItem(N'DD',default)         
SELECT @INV = Prefix FROM VoucherPrefix with (nolock) WHERE TranID = N'INVOICE'  
     
DECLARE @CGST AS INT = (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'CGST')
DECLARE @SGST AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'SGST')
DECLARE @IGST AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'IGST')
DECLARE @CESS AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'CESS')
DECLARE @ADDLCESS AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'ADDL CESS')
              
Declare @Payid as Int     
Create Table #Term(PaymentId Int)     
Truncate Table #Term       
if @term = 'Credit'      
Begin       
Truncate Table #Term       
Insert Into #Term Select 0      
End      
Else if @term  = 'Cash'      
Begin       
Truncate     
Table #Term       
Insert Into #Term Select 1  End      
Else if @term  = 'Cheque'       
Begin       
Truncate Table #Term       
Insert Into #Term Select 2      
End      
Else if @term  = 'DD'       
Begin       
Truncate Table #Term       
Insert Into #Term     
Select 3  End Else     
IF @term = '%'      
Begin       
Truncate Table #Term       
Insert Into #Term Select 0       
Insert Into #Term Select 1       
Insert Into #Term Select 2       
Insert Into #Term Select 3      
End      
    
select A.* into #InvoiceAbstract    
FROM InvoiceAbstract A with (nolock)                
WHERE  InvoiceType in (1,3)    
AND dbo.stripTimeFromdate(invoicedate) BETWEEN @FROMDATE AND @TODATE AND                 
(A.Status & 128) = 0 And                  
A.DocSerialType like @DocType             
and paymentMode  in (select Distinct PaymentId from #Term)     
    
select D.* into #invoicedetail    
from invoicedetail D with (nolock)    
Join #InvoiceAbstract A ON A.InvoiceID = D.InvoiceID    

select InvoiceID
--,Max([CGST%])
, sum(CGST) CGST
--, Max([SGST%])
, sum(SGST) SGST
--, Max([IGST%])
, sum(IGST) IGST
--, Max([CESS%])
, sum(CESS) CESS
, sum([ADDL CESS]) [ADDL CESS]
iNTO #TaxBreakup
 FROM (

SELECT  MAX(D.InvoiceID) InvoiceID,  
D.Product_Code
--,"CGST%"	= dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@CGST)
,"CGST"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@CGST) > 0 then dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@CGST)/100 else 0 end)  * ((SUM(D.SalePrice * Items.ReportingUnit))*(D.Quantity / Items.ReportingUnit) - SUM(D.DiscountValue))
--,"SGST%"	= dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@SGST)
,"SGST"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@SGST) > 0 then dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@SGST)/100 else 0 end)  * ((SUM(D.SalePrice * Items.ReportingUnit))*(D.Quantity / Items.ReportingUnit) - SUM(D.DiscountValue))
--,"IGST%"	= dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@IGST)
,"IGST"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@IGST) > 0 then dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@IGST)/100 else 0 end)  * ((SUM(D.SalePrice * Items.ReportingUnit))*(D.Quantity / Items.ReportingUnit) - SUM(D.DiscountValue))
--,"CESS%"	= dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@CESS)
,"CESS"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@CESS) > 0 then dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@CESS)/100 else 0 end)  * ((SUM(D.SalePrice * Items.ReportingUnit))*(D.Quantity / Items.ReportingUnit) - SUM(D.DiscountValue))
,"ADDL CESS"= dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),@ADDLCESS) * (D.Quantity)
FROM #InvoiceDetail D with (nolock), Items  with (nolock)--,Brand  with (nolock), UOM with (nolock)  
WHERE   --D.InvoiceID = 91984 AND  
D.Product_Code = Items.Product_Code  
--AND Items.BrandID = Brand.BrandID  AND  
--Items.ReportingUOM = UOM.UOM  
GROUP BY D.InvoiceID,D.Product_Code,-- Items.ProductName,Items.Description, Brand.BrandName,  
D.SalePrice, D.Quantity,Items.ReportingUnit-- , UOM.Description  
)X
Group by InvoiceID
 
SELECT  InvoiceID InvoiceID1,  
A.[GSTFullDocID] as InvoiceID,                     
"Date" = InvoiceDate,                
"CustomerID" = C.CustomerID,                       
"Customer" = C.Company_Name,                      
"GSTIN" = ISNULL(C.GSTIN,''),
"Goods Value" = GoodsValue,                       
"Product Discount" = ProductDiscount,           
"Total SalesTax Value" = TotalTaxApplicable,              
"Trade Discount" = Cast(A.GoodsValue * (DiscountPercentage /100) as Decimal(18,6)),                      
"Addl Discount" = A.GoodsValue * (AdditionalDiscount / 100),                      
Freight,        
"Net Value" = NetValue,         
"Round Off" = RoundOffAmount,                      
"Adjusted Amount" = IsNull(A.AdjustedAmount, 0),                      
"Balance" = A.Balance,                      
"Collected Amount" = NetValue - IsNull(A.AdjustedAmount, 0) - IsNull(A.Balance, 0) + IsNull(RoundOffAmount, 0),    
"Beat" = B.Description,     
"Salesman" = S.Salesman_Name,
"DsType" = dbo.fn_Get_DSTypeBySalesManId(S.SalesmanId),
"Document Type" = DocSerialType,     
"Doc Ref" = A.DocReference,    
"GSTFullDocID" = A.GSTFullDocID,  
"Payment Mode" = case IsNull(PaymentMode,0)      
When 0 Then @Credit                    
When 1 Then @Cash                      
When 2 Then @Cheque       
When 3 Then @DD                      
Else @Credit             
End    
,"OldInvoiceID" = @INV + CAST(DocumentID AS nVARCHAR)         
,"CGST"	= (select top 1 [CGST]  from #TaxBreakup T  where A.InvoiceID = T.InvoiceID)
,"SGST"	= (select top 1 [SGST]  from #TaxBreakup T  where A.InvoiceID = T.InvoiceID)
,"IGST"	= (select top 1 [IGST]  from #TaxBreakup T  where A.InvoiceID = T.InvoiceID)
,"CESS"	= (select top 1 [CESS]  from #TaxBreakup T  where A.InvoiceID = T.InvoiceID)
,"ADDL CESS"	= (select top 1 [ADDL CESS]  from #TaxBreakup T  where A.InvoiceID = T.InvoiceID)
  
FROM #InvoiceAbstract A with (nolock)
Join Customer C with (nolock) ON C.CustomerID = A.CustomerID
Left Join Salesman S with (nolock) ON S.SalesManId = A.SalesmanID
Left Join Beat B with (nolock) ON B.BeatID = A.BeatID
WHERE  InvoiceType in (1,3)      
AND dbo.stripTimeFromdate(invoicedate) BETWEEN @FROMDATE AND @TODATE AND      
A.CustomerID = C.CustomerID AND         
(A.Status & 128) = 0 And                    
A.DocSerialType like @DocType               
and paymentMode  in (select Distinct PaymentId from #Term)       
Order By  DocumentID     
    
  
Drop Table #Term     
    
     
END

