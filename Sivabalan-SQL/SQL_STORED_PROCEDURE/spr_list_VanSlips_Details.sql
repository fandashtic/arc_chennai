
CREATE procedure spr_list_VanSlips_Details (@DocCount int, @UOM Varchar(256))    
as          
    
If @UOM = N'Base UOM' or @UOM = N'%'     
 Set @UOM = N'Sales UOM'      
     
If @UOM = 'Sales UOM'      
 Select  VanStatementDetail.Product_Code,           
   "Item Name" = Items.ProductName,           
   "Batch Number" = VanStatementDetail.Batch_Number,          
   "Expiry" = Batch_Products.Expiry,          
   "PKD" = Batch_Products.PKD,          
   "Sale Price" = VanStatementDetail.SalePrice,           
   "Total Quantity" = Cast(Sum(IsNull(VanStatementDetail.Quantity,0)) as NVarchar) + N' ' + IsNull(UOM.Description,''),           
   "Amount" = Sum(VanStatementDetail.Amount),          
   "Sold Quantity" = Cast(Sum(IsNull(VanStatementDetail.Quantity,0) - IsNull(VanStatementDetail.Pending,0)) as NVarchar) + N' ' + IsNull(UOM.Description,''),          
   "Unsold Quantity" = Cast(Sum(IsNull(VanStatementDetail.Pending,0)) as NVarchar) + N' ' + IsNull(UOM.Description,'')         
 From VanStatementDetail
 Inner Join Items ON VanStatementDetail.Product_Code = Items.Product_Code
 Left Outer Join Batch_Products ON VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
 Left Outer Join UOM ON Items.UOM = UOM.UOM
 Where
	VanStatementDetail.DocSerial = @doccount           
 Group by          
   VanStatementDetail.Product_Code,          
   Items.ProductName,          
   VanStatementDetail.Batch_Number,          
   Batch_Products.Expiry,Batch_Products.PKD,          
   VanStatementDetail.SalePrice, UOM.Description      
Else If @UOM = 'Conversion Factor'      
 Select  VanStatementDetail.Product_Code,           
   "Item Name" = Items.ProductName,           
   "Batch Number" = VanStatementDetail.Batch_Number,          
   "Expiry" = Batch_Products.Expiry,          
   "PKD" = Batch_Products.PKD,          
   "Sale Price" = VanStatementDetail.SalePrice,           
   "Total Quantity" = Cast((CASE IsNull(Items.ConversionFactor,0)       
  WHEN 0 THEN 1       
  ELSE IsNull(Items.ConversionFactor,0) END) * Sum(IsNull(VanStatementDetail.Quantity,0)) as NVarchar) + N' ' + IsNull(ConversionTable.ConversionUnit,''),       
   "Amount" = sum(VanStatementDetail.Amount),          
   "Sold Quantity" = Cast((CASE IsNull(Items.ConversionFactor,0)       
  WHEN 0 THEN 1       
  ELSE IsNull(Items.ConversionFactor,0) END) * Sum(IsNull(VanStatementDetail.Quantity,0) - IsNull(VanStatementDetail.Pending,0)) as NVarchar) + N' ' + IsNull(ConversionTable.ConversionUnit,''),      
   "Unsold Quantity" = Cast((CASE IsNull(Items.ConversionFactor,0)       
  WHEN 0 THEN 1       
  ELSE IsNull(Items.ConversionFactor,0) END) * Sum(IsNull(VanStatementDetail.Pending,0)) as Nvarchar) + N' ' + IsNull(ConversionTable.ConversionUnit,'')         
  From VanStatementDetail
  Inner Join Items ON VanStatementDetail.Product_Code = Items.Product_Code
  Left Outer Join Batch_Products ON VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
  Left Outer Join ConversionTable ON Items.ConversionUnit = ConversionTable.ConversionID
  Where
	VanStatementDetail.DocSerial = @doccount           
  Group by VanStatementDetail.Product_Code,          
   Items.ProductName, Items.ConversionFactor, ConversionTable.ConversionUnit,         
   VanStatementDetail.Batch_Number,          
   Batch_Products.Expiry,Batch_Products.PKD,          
   VanStatementDetail.SalePrice      
Else If @UOM = 'Reporting UOM'      
  Select  VanStatementDetail.Product_Code,           
   "Item Name" = Items.ProductName,           
   "Batch Number" = VanStatementDetail.Batch_Number,          
   "Expiry" = Batch_Products.Expiry,          
   "PKD" = Batch_Products.PKD,          
   "Sale Price" = VanStatementDetail.SalePrice,      
   "Total Quantity" = Cast(dbo.sp_Get_ReportingUOMQty(VanStatementDetail.Product_Code, Sum(IsNull(VanStatementdetail.Quantity,0))) as NVarchar) + N' ' + IsNull(UOM.Description,''),      
   "Amount" = Sum(VanStatementDetail.Amount),          
   "Sold Quantity" = Cast(dbo.sp_Get_ReportingUOMQty(VanStatementDetail.Product_Code, Sum(IsNull(VanStatementDetail.Quantity,0) - IsNull(VanStatementDetail.Pending,0))) as NVarchar) + N' ' + IsNull(UOM.Description,''),       
   "Unsold Quantity" = Cast(dbo.sp_Get_ReportingUOMQty(VanStatementDetail.Product_Code, Sum(IsNull(VanStatementDetail.Pending,0))) as NVarchar) + N' ' + IsNull(UOM.Description,'')         
  From VanStatementDetail
  Inner Join Items ON VanStatementDetail.Product_Code = Items.Product_Code
  Left Outer Join Batch_Products ON VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
  Left Outer Join UOM ON Items.ReportingUOM = UOM.UOM
  Where
	VanStatementDetail.DocSerial = @doccount           
  Group by VanStatementDetail.Product_Code,          
   Items.ProductName,          
   VanStatementDetail.Batch_Number,          
   Batch_Products.Expiry,Batch_Products.PKD,          
   VanStatementDetail.SalePrice, UOM.Description      
Else If @UOM = 'Case UOM'      
 Select  VanStatementDetail.Product_Code,           
   "Item Name" = Items.ProductName,           
   "Batch Number" = VanStatementDetail.Batch_Number,          
   "Expiry" = Batch_Products.Expiry,          
   "PKD" = Batch_Products.PKD,          
   "Sale Price" = VanStatementDetail.SalePrice,       
   "Total Quantity" =dbo.sp_Get_CaseUOMQty(VanStatementDetail.Product_Code, Sum(IsNull(VanStatementdetail.Quantity,0))),      
   "Amount" = sum(VanStatementDetail.Amount),          
   "Sold Quantity" = dbo.sp_Get_CaseUOMQty(VanStatementDetail.Product_Code,Sum(IsNull(VanStatementdetail.Quantity,0))-Sum(IsNull(VanStatementDetail.Pending,0))),      
   "Unsold Quantity" = dbo.sp_Get_CaseUOMQty(VanStatementDetail.Product_Code, Sum(IsNull(VanStatementDetail.Pending,0)))      
 From VanStatementDetail
 Inner Join Items ON VanStatementDetail.Product_Code = Items.Product_Code
 Left Outer Join Batch_Products ON VanStatementDetail.Batch_Code = Batch_Products.Batch_Code
 Left Outer Join UOM ON Items.Case_UOM = UOM.UOM
 Where
	VanStatementDetail.DocSerial = @doccount           
 Group by VanStatementDetail.Product_Code,          
   Items.ProductName, Items.Case_Conversion,      
   VanStatementDetail.Batch_Number,          
   Batch_Products.Expiry,Batch_Products.PKD,          
   VanStatementDetail.SalePrice, UOM.Description      
  
