CREATE PROCEDURE [dbo].[spr_list_invoices_by_beat_abstract_Van](@VAN nVARCHAR(100),@FROMDATE DATETIME,      
          @TODATE DATETIME)      
AS      
Declare @OTHERS As NVarchar(50)
Set @OTHERS = dbo.LookupDictionaryItem(N'Others',Default)

select    
"BeatVan" = Convert(nVarchar,case Isnull(Beat.Description,N'') When N'' Then 0 Else Beat.BeatID End) + 
 Char(15) + Van.Van,
--"BeatID" = case Isnull(Beat.Description,'') When '' Then 0 Else Beat.BeatID End,      
"Beat" = IsNull(Beat.Description, @OTHERS),       
"Van" = Van.Van,  
"Net Value (%c)" = Sum(distinct NetValue),      
"Balance (%c)" = Sum(distinct Balance),      
"Quantity" = Sum(Quantity),    
"KGS/Ltr" = sum(isnull(Quantity, 0) / Case isnull(Items.reportingunit, 1)     
           When 0 Then 1 Else isnull(Items.reportingunit, 1) End)    
-- Case When Count(DISTINCT Items.ReportingUOM) <=1 Then    
--        Case When IsNull(Max(Items.ReportingUnit),0) > 0     
--        Then Cast(Cast(Sum(Quantity)/Max(Items.ReportingUnit) as Decimal(18,2)) as nVarchar) End End
-- --+ ' ' + Max(uom.[Description]) End    
-- --       End    
FROM InvoiceAbstract
Left Outer Join Beat  On InvoiceAbstract.BeatID = Beat.BeatID 
Inner Join InvoiceDetail On InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID
Inner Join Items On InvoiceDetail.Product_Code = Items.Product_Code
Left Outer Join uom On uom.uom = Items.ReportingUOM
Inner Join Van On InvoiceAbstract.VanNumber=Van.Van
WHERE   InvoiceType in (1, 3) AND      
 (Status & 128) = 0 AND       
 Van.van_number Like @VAN AND
-- InvoiceAbstract.VanNumber Like @VAN AND
--=@VAN AND   
 InvoiceAbstract.InvoiceDate BETWEEN @FROMDATE AND @TODATE      
GROUP BY Beat.BeatID,Beat.Description,Van.Van      

