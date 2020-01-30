
CREATE Procedure spr_list_PartywisePackingwiseSales_Detail_pidilite (@Customer nVarChar(50),       
@FromDate DateTime, @ToDate DateTime)      
As      
Select it.Product_Code ,   
"Category" = itcat.Category_Name,  
"Item Code" = it.Product_Code , "Item Name" = ProductName ,       
"Invoice No" = vp.Prefix + cast(ia.DocumentID as nvarchar) ,    
"Document No" = ia.DocReference,
"Quantity" = Sum(Case ide.SalePrice     
When 0 then 0    
Else     
 (Case InvoiceType     
 When 4 Then -1     
 Else 1 End) * Quantity     
End),    
     
"Reporting UOM" = Sum(Case ide.SalePrice     
When 0 then 0    
Else     
 (Case InvoiceType     
 When 4 Then -1     
 Else 1 End) * (Quantity / Case IsNull(it.ReportingUnit, 1) When 0 Then 1 Else IsNull(it.ReportingUnit, 1) End)  
End),    
  
--IsNull((Select isnull(uom.description, '') from UOM Where uom.uom = it.reportingUOM ), ''),      
"Conversion Factor" = Sum(Case ide.SalePrice     
When 0 then 0    
Else     
 (Case InvoiceType     
 When 4 Then -1     
 Else 1 End) * (Quantity * ConversionFactor)  
End),    
  
--isnull((select isnull(conversiontable.conversionunit, '') from conversiontable where conversiontable.Conversionid = it.Conversionunit), ''),      
"Free Quantity" =     
Sum(Case ide.SalePrice     
When 0 then     
(Case InvoiceType     
When 4 Then -1     
Else 1 End) * Quantity    
Else 0 End),       
"Rate" = Max(ide.SalePrice),    
"Discount" = Sum(ide.DiscountValue) ,    
"Value" = Sum((Case InvoiceType When 4 Then -1 Else 1 End) * Amount)     
From Items it , ItemCategories itcat, InvoiceDetail ide , InvoiceAbstract ia , VoucherPrefix vp    
Where  it.CategoryID = itcat.CategoryID And  
it.Product_Code = ide.Product_Code     
And ide.InvoiceID = ia.InvoiceID     
And IsNull(CustomerID, '') Like @Customer     
And InvoiceDate Between @FromDate And @ToDate     
And (IsNull(Status, 0) & 192) = 0     
And InvoiceType != 2     
And vp.TranID = N'INVOICE'    
Group By itcat.Category_Name, ProductName, it.Product_Code , ia.InvoiceID ,    
vp.Prefix + cast(ia.DocumentID as nvarchar), it.ReportingUOM, it.ConversionUnit,
ia.DocReference
   
    
    
