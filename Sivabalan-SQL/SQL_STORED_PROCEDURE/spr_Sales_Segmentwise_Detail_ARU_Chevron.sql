Create Procedure spr_Sales_Segmentwise_Detail_ARU_Chevron
(  
 @SegmentID BigInt,  
 @FromDate Datetime,  
 @ToDate DateTime  
)  
As   
Set DateFormat DMY  
Set @FromDate= dbo.StripDateFromTime(@FromDate)  
Set @ToDate= dbo.StripDateFromTime(@ToDate)  
  
Select   
 IDE.Product_Code,  
 "Item Code" = IDE.Product_Code,  
 "Item Name" = IT.ProductName,  
 "Quantity" = Cast(Sum(IDE.Quantity) / Case IsNull(IT.ReportingUnit,0) When 0 Then 1 Else IT.ReportingUnit End As NVarChar)+ ' ' + Cast((Select IsNull(Description,'') From UOM Where UOM = IT.ReportingUOM) As NVarChar),
 "Batch" = IDE.Batch_Number,  
 "Quantity" = Cast(Sum(IDE.Quantity) As NVarChar)+ ' ' + Cast((Select Description From UOM Where UOM = IT.UOM) As NVarChar),  
 "Sale Price   (%c)" = IsNull(IDE.SalePrice,0),  
 "Sale Tax" = Cast(Max(IDE.TaxCode+IDE.TaxCode2) As NVarChar) + '%',  
 "Tax Suffered" = Cast(IsNull(Max(IDE.TaxSuffered),0) As NVarChar) + '%',  
 "Discount" = Cast(Sum(IDE.DiscountPercentage) As NVarChar) + '%',  
 "STCredit  (%c)" = Sum(IDE.STCredit),  
 "Total  (%c)" = Sum(IDE.Amount),  
 "Forum Code" = IT.Alias  
From  
 CustomerSegment CS,Customer C,InvoiceAbstract IA,InvoiceDetail IDE,Items IT  
Where  
 CS.SegmentID = @SegmentID  
 And CS.SegmentID = C.SegmentID  
 And C.CustomerID = IA.CustomerID  
 And dbo.StripDateFromTime(IA.InvoiceDate) >= @FromDate  
 And dbo.StripDateFromTime(IA.InvoiceDate) <= @ToDate  
 And IsNull(IA.Status,0) & 128 = 0  
 And IA.InvoiceID = IDE.InvoiceID  
 And IDE.Product_Code = IT.Product_Code  
Group By  
 IDE.Product_Code,IT.ProductName,IT.ReportingUnit,IT.ReportingUOM,
 IT.UOM,IDE.Batch_Number,IT.Alias,IDE.SalePrice  

