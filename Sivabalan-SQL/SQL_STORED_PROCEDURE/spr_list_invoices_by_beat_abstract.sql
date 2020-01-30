CREATE PROCEDURE [dbo].[spr_list_invoices_by_beat_abstract](@FROMDATE DATETIME,  
          @TODATE DATETIME)  
AS  
Declare @OTHERS As NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)

select   
"BeatID" = case Isnull(Beat.Description,N'') When N'' Then 0 Else Beat.BeatID End,  
"Beat" = IsNull(Beat.Description, @OTHERS),   
"Net Value (%c)" = Sum(Amount),  
"Balance (%c)" = (Select Sum(Balance) From InvoiceAbstract a
Left Outer Join Beat b On a.BeatID = b.BeatID 
Where a.InvoiceType in (1, 3) AND (a.Status & 128) = 0 AND  a.InvoiceDate BETWEEN @FROMDATE AND @TODATE AND a.BeatID = InvoiceAbstract.BeatID), "Quantity" = Sum(Quantity),
"Reporting Unit" = Case When Count(DISTINCT Items.ReportingUOM) <=1 Then
				   Case When IsNull(Max(Items.ReportingUnit),0) > 0 
				   Then Cast(Cast(Sum(Quantity)/Max(Items.ReportingUnit) as Decimal(18,2)) as nVarchar) + N' ' + Max(uom.[Description]) End
				   End
FROM InvoiceAbstract
Left Outer Join Beat  On  InvoiceAbstract.BeatID = Beat.BeatID 
Inner Join  InvoiceDetail  On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
Inner Join  Items  On InvoiceDetail.Product_Code = Items.Product_Code
Left Outer Join uom On uom.uom = Items.ReportingUOM
WHERE   InvoiceType in (1, 3) AND  
 (Status & 128) = 0 And
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE  
GROUP BY Beat.BeatID, Beat.Description, InvoiceAbstract.BeatID
ORDER BY Beat.Description


