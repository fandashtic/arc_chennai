--Set DateFormat DMY
--Exec spr_list_SR_MUOM_Top_new '09-Jan-2019','09-Jan-2019','%'
CREATE PROCEDURE [dbo].[spr_list_SR_MUOM_Top_new]
( 
@FROMDATE datetime, 
@TODATE datetime, 
@DocType nvarchar(100)
) 
AS 
DECLARE @INV AS NVARCHAR(50) 
DECLARE @CASH AS NVARCHAR(50)
DECLARE @CREDIT AS NVARCHAR(50)                 
DECLARE @CHEQUE AS NVARCHAR(50)
DECLARE @DD AS NVARCHAR(50)
SELECT @CASH = DBO.LookUpDictionaryItem(N'Cash',default) 
SELECT @CREDIT = DBO.LookUpDictionaryItem(N'Credit',default) 
SELECT @CHEQUE = DBO.LookUpDictionaryItem(N'Cheque',default)
SELECT @DD = DBO.LookUpDictionaryItem(N'DD',default) 
SELECT @INV = Prefix FROM VoucherPrefix WITH (NOLOCK)
WHERE TranID = N'INVOICE'

select IA.* into #InvoiceAbstract    
FROM InvoiceAbstract IA with (nolock)                
WHERE  InvoiceType=4 
AND InvoiceDate BETWEEN @FROMDATE AND @TODATE 
And (IA.Status & 128) = 0 
And  IA.DocSerialType like @DocType              
     
    
select D.* into #invoicedetail    
from invoicedetail D with (nolock)    
Join #InvoiceAbstract A ON A.InvoiceID = D.InvoiceID    

select InvoiceID
,Max([CGST%])[CGST%]
, sum(CGST) CGST
, Max([SGST%])[SGST%]
, sum(SGST) SGST
, Max([IGST%])[IGST%]
, sum(IGST) IGST
, Max([CESS%])[CESS%]
, sum(CESS) CESS
, sum([ADDL CESS]) [ADDL CESS]
iNTO #TaxBreakup
 FROM (

SELECT  MAX(D.InvoiceID) InvoiceID,  
D.Product_Code
,"CGST%"	= dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),2)
,"CGST"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),2) > 0 then dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),2)/100 else 0 end)  * ((SUM(D.SalePrice * Items.ReportingUnit))*(D.Quantity / Items.ReportingUnit) - SUM(D.DiscountValue))
,"SGST%"	= dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),3)
,"SGST"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),3) > 0 then dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),3)/100 else 0 end)  * ((SUM(D.SalePrice * Items.ReportingUnit))*(D.Quantity / Items.ReportingUnit) - SUM(D.DiscountValue))
,"IGST%"	= dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),4)
,"IGST"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),4) > 0 then dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),4)/100 else 0 end)  * ((SUM(D.SalePrice * Items.ReportingUnit))*(D.Quantity / Items.ReportingUnit) - SUM(D.DiscountValue))
,"CESS%"	= dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),5)
,"CESS"	 = (case when dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),5) > 0 then dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),5)/100 else 0 end)  * ((SUM(D.SalePrice * Items.ReportingUnit))*(D.Quantity / Items.ReportingUnit) - SUM(D.DiscountValue))
,"ADDL CESS"= dbo.[fn_GetTaxValueByComponent](Max(D.TaxID),6) * (D.Quantity)
FROM #InvoiceDetail D with (nolock), Items  with (nolock)--,Brand  with (nolock), UOM with (nolock)  
WHERE   --D.InvoiceID = 91984 AND  
D.Product_Code = Items.Product_Code  
--AND Items.BrandID = Brand.BrandID  AND  
--Items.ReportingUOM = UOM.UOM  
GROUP BY D.InvoiceID,D.Product_Code,-- Items.ProductName,Items.Description, Brand.BrandName,  
D.SalePrice, D.Quantity,Items.ReportingUnit-- , UOM.Description  
)X
Group by InvoiceID

SELECT  
InvoiceID, 
IA.[GSTFullDocID] as InvoiceID,                     
--"InvoiceID" = @INV + CAST(DocumentID AS nVARCHAR), 
"Date" = InvoiceDate,
"CustomerID" = C.CustomerID, 
"Customer" = C.Company_Name, 
"Goods Value" = GoodsValue, 
"Product Discount" = ProductDiscount, 
"Total SalesTax Value" = TotalTaxApplicable,          
--"Trade Discount%" = CAST(Cast(DiscountPercentage as Decimal(18,6)) AS nvarchar) + N'%',
"Trade Discount" = Cast(IA.GoodsValue * (DiscountPercentage /100) as Decimal(18,6)),                  
--"Addl Discount%" = CAST(AdditionalDiscount AS nvarchar) + N'%',                  
"Addl Discount" = IA.GoodsValue * (AdditionalDiscount / 100),
Freight, 
"Net Value" = NetValue,   
"Round Off" = RoundOffAmount,                  
--"Adj Ref" = IsNull(IA.AdjRef, N''),                  
"Adjusted Amount" = IsNull(IA.AdjustedAmount, 0),
"Balance" = IA.Balance,
"Collected Amount" = NetValue - IsNull(IA.AdjustedAmount, 0) - IsNull(IA.Balance, 0) + IsNull(RoundOffAmount, 0),                  
"Beat" = B.Description,                  
"Salesman" = S.Salesman_Name,    
"Document Type" = DocSerialType,
"Doc Ref" = IA.DocReference, 
"Payment Mode" = case IsNull(PaymentMode,0) 
	When 0 Then @Credit 
	When 1 Then @Cash 
	When 2 Then @Cheque       
	When 3 Then @DD 
	Else @Credit 
	End 

,"OldInvoiceID" = @INV + CAST(DocumentID AS nVARCHAR)         
,"CGST%"	= (select top 1 [CGST%]  from #TaxBreakup T  where IA.InvoiceID = T.InvoiceID)
,"CGST"	= (select top 1 [CGST]  from #TaxBreakup T  where IA.InvoiceID = T.InvoiceID)
,"SGST%"	= (select top 1 [SGST%]  from #TaxBreakup T  where IA.InvoiceID = T.InvoiceID)
,"SGST"	= (select top 1 [SGST]  from #TaxBreakup T  where IA.InvoiceID = T.InvoiceID)
,"IGST%"	= (select top 1 [IGST%]  from #TaxBreakup T  where IA.InvoiceID = T.InvoiceID)
,"IGST"	= (select top 1 [IGST]  from #TaxBreakup T  where IA.InvoiceID = T.InvoiceID)
,"CESS%"	= (select top 1 [CESS%]  from #TaxBreakup T  where IA.InvoiceID = T.InvoiceID)
,"CESS"	= (select top 1 [CESS]  from #TaxBreakup T  where IA.InvoiceID = T.InvoiceID)
,"ADDL CESS"	= (select top 1 [ADDL CESS]  from #TaxBreakup T  where IA.InvoiceID = T.InvoiceID)
  
FROM #InvoiceAbstract IA with (nolock)
Join Customer C with (nolock) ON C.CustomerID = IA.CustomerID
Join Salesman S with (nolock) ON S.SalesManId = IA.SalesmanID
Join Beat B with (nolock) ON B.BeatID = IA.BeatID

--FROM #InvoiceAbstract IA WITH (NOLOCK), 
--Customer C WITH (NOLOCK), 
--Beat B WITH (NOLOCK), 
--Salesman S WITH (NOLOCK)
WHERE  IA.InvoiceType=4 
AND IA.InvoiceDate BETWEEN @FROMDATE AND @TODATE
--AND IA.CustomerID = C.CustomerID 
--AND IA.BeatID *= B.BeatID 
--And IA.SalesmanID *= S.SalesmanID 
And (IA.Status & 128) = 0 
And  IA.DocSerialType like @DocType              
Order By  DocumentID
