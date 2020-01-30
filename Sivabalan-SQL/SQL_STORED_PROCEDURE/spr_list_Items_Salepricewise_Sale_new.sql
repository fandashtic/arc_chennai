--exec spr_list_Items_Salepricewise_Sale_new '2019-04-04 00:00:00','2019-04-04 23:59:59','%','Yes'
CREATE procedure [dbo].[spr_list_Items_Salepricewise_Sale_new]  
(  
 @FROMDATE datetime,  
 @TODATE datetime,  
 @PaymentMode nVarchar(50),
 @WithGST nVarchar(50) = '%'
)     
AS     

DECLARE @CGST AS INT = (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'CGST')
DECLARE @SGST AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'SGST')
DECLARE @IGST AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'IGST')
DECLARE @CESS AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'CESS')
DECLARE @ADDLCESS AS INT= (SELECT  TOP 1 ISNULL(TaxComponent_code, 0) FROM TaxComponentDetail WHERE TaxComponent_desc = 'ADDL CESS')

Declare @CUSTOMER AS TABLE (CUSTOMERId NVARCHAR(255))
IF(UPPER(@WithGST) = UPPER('yes'))
Begin	
	INSERT INTO @CUSTOMER(CUSTOMERId)
	SELECT DISTINCT CUSTOMERId FROM CUSTOMER WITH(NOLOCK) WHERE ISNULL(GSTIN, '') <> '' 
End
Else IF(UPPER(@WithGST) = UPPER('no'))
Begin	
	INSERT INTO @CUSTOMER(CUSTOMERId)
	SELECT DISTINCT CUSTOMERId FROM CUSTOMER WITH(NOLOCK) WHERE ISNULL(GSTIN, '') = '' 
End
Else
Begin	
	INSERT INTO @CUSTOMER(CUSTOMERId)
	SELECT DISTINCT CUSTOMERId FROM CUSTOMER WITH(NOLOCK)
End
   
SELECT distinct D.Product_Code,     
"Category" = B.BrandName,     
"Item Code" = D.Product_Code,     
"Item Name" = I.ProductName,      
"Sale Price" = D.SalePrice * I.ReportingUnit,     
"Quantity" = SUM( D.Quantity / I.ReportingUnit),     
"Gross Amount(%c)"= (D.SalePrice * I.ReportingUnit)*(SUM( D.Quantity / I.ReportingUnit)),     
"Discount(%c)"=Sum(IsNull(D.SCHEMEDISCAMOUNT, 0) + IsNull(D.SPLCATDISCAMOUNT, 0)),     
"SCP%(%c)"=Sum(IsNull(D.DiscountValue, 0) - (IsNull(D.SCHEMEDISCAMOUNT, 0) +    IsNull(D.SPLCATDISCAMOUNT, 0)))   
--"Discount Value" = SUM(D.DiscountValue),     

,"CGST%" = dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@CGST)  
,"CGST" = (CASE WHEN dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@CGST) >  0 THEN  dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@CGST) / 100 ELSE 0 END) * ((D.SalePrice * I.ReportingUnit)*(SUM( D.Quantity / I.ReportingUnit)) - Sum(IsNull(D.SCHEMEDISCAMOUNT, 0) + IsNull(D.SPLCATDISCAMOUNT, 0)))  
,"SGST%" = dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@SGST)  
,"SGST" = (CASE WHEN dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@SGST) >  0 THEN  dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@SGST) / 100 ELSE 0 END) * ((D.SalePrice * I.ReportingUnit)*(SUM( D.Quantity / I.ReportingUnit)) - Sum(IsNull(D.SCHEMEDISCAMOUNT, 0) + IsNull(D.SPLCATDISCAMOUNT, 0)))  
,"IGST%" = dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@IGST)  
,"IGST" = (CASE WHEN dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@IGST) >  0 THEN  dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@IGST) / 100 ELSE 0 END) * ((D.SalePrice * I.ReportingUnit)*(SUM( D.Quantity / I.ReportingUnit)) - Sum(IsNull(D.SCHEMEDISCAMOUNT, 0) + IsNull(D.SPLCATDISCAMOUNT, 0)))  
,"CESS%" = dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@CESS)  
,"CESS" = (CASE WHEN dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@CESS) >  0 THEN  dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@CESS) / 100 ELSE 0 END) * ((D.SalePrice * I.ReportingUnit)*(SUM( D.Quantity / I.ReportingUnit)) - Sum(IsNull(D.SCHEMEDISCAMOUNT, 0) + IsNull(D.SPLCATDISCAMOUNT, 0)))  
,"ADDL CESS" = dbo.fn_GetTaxValueByComponent(MAX(D.TaxID),@ADDLCESS)  * SUM(D.Quantity)
,"TOTAL DIS" = Sum(IsNull(D.SCHEMEDISCAMOUNT, 0) + IsNull(D.SPLCATDISCAMOUNT, 0)) + 
               Sum(IsNull(D.DiscountValue, 0) - (IsNull(D.SCHEMEDISCAMOUNT, 0) +    IsNull(D.SPLCATDISCAMOUNT, 0)))   
,"Sales Tax Value(%c)" = Isnull(Sum(D.STPayable + D.CSTPayable), 0)
,"Total(%c)" = Round(SUM(D.Amount),2)  
,"With GST" = (CASE WHEN @WithGST = '%' THEN 'All' ELSE UPPER(@WithGST) END)
FROM InvoiceDetail D WITH (nolock)  
,Items I with (nolock)   
,Brand    B with (nolock)  
WHERE D.Product_Code = I.Product_Code   
And   D.InvoiceID IN      
(Select IA.InvoiceID   
  from InvoiceAbstract IA with (nolock)
  JOIN @CUSTOMER C ON C.CustomerId = IA.CustomerId    
where IA.InvoiceDate BETWEEN @FROMDATE AND @TODATE
AND   IA.PaymentMode IN    
(Select Paymentterm.mode   
from Paymentterm   
where Paymentterm.value like @PaymentMode)   
And    (IA.Status & 128) = 0   
AND   IA.InvoiceType in (1,3))   
AND   I.BrandID = B.BrandID         
GROUP BY B.BrandName  
,D.Product_Code  
, I.ProductName  
,D.SalePrice  
,I.ReportingUnit  
,D.SalePrice     
order by B.BrandName
