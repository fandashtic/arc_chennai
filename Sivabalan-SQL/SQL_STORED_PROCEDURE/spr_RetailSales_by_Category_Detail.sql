CREATE procedure [dbo].[spr_RetailSales_by_Category_Detail] (@InvID nvarchar(512))          
AS          
Declare @INVOICEID int  
Declare @CategoryID nvarchar(255)  
Declare @Pos int  
Declare @InvType int  
Declare @Status int  
  
Set @Pos = charindex(N';', @InvID)  
Set @INVOICEID = cast(substring(@InvID, 1, @Pos-1) as int)  
Set @CategoryID = substring(@InvID, @Pos + 1, 255)  
  
Select @InvType = InvoiceType from InvoiceAbstract WHERE   InvoiceAbstract.InvoiceID = @INVOICEID  
Select @Status = Status from InvoiceAbstract WHERE   InvoiceAbstract.InvoiceID = @INVOICEID  
  
Create Table #tempCategory(CategoryID int, Status int)        
Exec GetSubCategories @CategoryID      
  
If (@InvType = 1 and @Status & 16 = 16)  
begin  
 SELECT InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,           
 "Item Name" = Items.ProductName,           
 "Batch" = InvoiceDetail.Batch_Number,          
 Batch_Products.PKD, Batch_Products.Expiry,         
 "Manufacturer Name" =  Manufacturer.Manufacturer_Name,        
 "Quantity" =     
 sum(Case     
 When InvoiceAbstract.InvoiceType>=4 and InvoiceAbstract.InvoiceType<=6 Then 0 - InvoiceDetail.Quantity     
 Else InvoiceDetail.Quantity       
 End),  
 "Reporting UOM" = dbo.sp_Get_ReportingUOMQty(InvoiceDetail.Product_Code, sum(Case 
  When InvoiceAbstract.InvoiceType>=4 and InvoiceAbstract.InvoiceType<=6 Then 0 - InvoiceDetail.Quantity     
  Else InvoiceDetail.Quantity       
  End)),  
--  "Reporting UOM" = sum(Case InvoiceAbstract.InvoiceType     
--  When 4 Then 0 - InvoiceDetail.Quantity     
--  Else InvoiceDetail.Quantity       
--  End) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End),  
 "UOM Description" = IsNull((Select [Description] From UOM Where UOM = Items.ReportingUOM) , N''),  
 "Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0),  
 "Amount" =  Sum(Case 
 WHEN InvoiceAbstract.InvoiceType>=4 and InvoiceAbstract.InvoiceType<=6 THEN  
 0 - IsNull(InvoiceDetail.Quantity,0)   
 ELSE  
 IsNull(InvoiceDetail.Quantity,0) END  
 * IsNull(InvoiceDetail.SalePrice,0))       
 FROM InvoiceDetail, Items, Batch_Products, Manufacturer, ItemCategories, InvoiceAbstract, VanStatementDetail   
 WHERE   InvoiceDetail.InvoiceID = @INVOICEID  AND          
 InvoiceDetail.Product_Code = Items.Product_Code  AND        
 InvoiceDetail.Product_Code *= Batch_Products.Product_Code AND        
 Items.ManufacturerID = Manufacturer.ManufacturerID  And    
 Items.CategoryID = ItemCategories.CategoryID And    
 ItemCategories.CategoryID in (Select CategoryID from #tempCategory) AND  
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID AND  
 InvoiceDetail.Batch_Code = VanStatementDetail.[ID]  AND  
 VanStatementDetail.Batch_Code *= Batch_Products.Batch_Code  
 GROUP BY InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number, Batch_Products.PKD,       
 Batch_Products.Expiry, Manufacturer.Manufacturer_Name, InvoiceDetail.SalePrice,  
 Items.ReportingUnit, Items.ReportingUOM      
end  
else   
begin  
 SELECT InvoiceDetail.Product_Code, "Item Code" = InvoiceDetail.Product_Code,           
 "Item Name" = Items.ProductName,           
 "Batch" = InvoiceDetail.Batch_Number,          
 Batch_Products.PKD, Batch_Products.Expiry,         
 "Manufacturer Name" =  Manufacturer.Manufacturer_Name,        
 "Quantity" =     
 sum(Case      
 When InvoiceAbstract.InvoiceType>=4 and InvoiceAbstract.InvoiceType<=6 Then 0 - InvoiceDetail.Quantity     
 Else InvoiceDetail.Quantity       
 End),  
 "Reporting UOM" = dbo.sp_Get_ReportingUOMQty(InvoiceDetail.Product_Code, sum(Case    
  When InvoiceAbstract.InvoiceType>=4 and InvoiceAbstract.InvoiceType<=6 Then 0 - InvoiceDetail.Quantity     
  Else InvoiceDetail.Quantity       
  End)),  
  
--  "Reporting UOM" = sum(Case InvoiceAbstract.InvoiceType     
--  When 4 Then 0 - InvoiceDetail.Quantity     
--  Else InvoiceDetail.Quantity 
--  End) / (Case IsNull(Items.ReportingUnit, 0) When 0 Then 1 Else Items.ReportingUnit End),  
 "UOM Description" = IsNull((Select [Description] From UOM Where UOM = Items.ReportingUOM) , N''),  
 "Sale Price" = ISNULL(InvoiceDetail.SalePrice, 0),  
 "Amount" =  Sum(Case   
 WHEN InvoiceAbstract.InvoiceType>=4 and InvoiceAbstract.InvoiceType<=6 THEN  
 0 - IsNull(InvoiceDetail.Quantity,0)   
 ELSE  
 IsNull(InvoiceDetail.Quantity,0) END  
 * IsNull(InvoiceDetail.SalePrice,0))  
 FROM InvoiceDetail, Items, Batch_Products, Manufacturer, ItemCategories, InvoiceAbstract  
 WHERE   InvoiceDetail.InvoiceID = @INVOICEID  AND          
 InvoiceDetail.Product_Code = Items.Product_Code  AND        
 InvoiceDetail.Product_Code *= Batch_Products.Product_Code AND        
 InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code And      
 Items.ManufacturerID = Manufacturer.ManufacturerID  And    
 Items.CategoryID = ItemCategories.CategoryID And    
 ItemCategories.CategoryID in (Select CategoryID from #tempCategory) AND  
 InvoiceAbstract.InvoiceID = InvoiceDetail.InvoiceID  
 GROUP BY InvoiceDetail.Product_Code, Items.ProductName, InvoiceDetail.Batch_Number, Batch_Products.PKD,       
 Batch_Products.Expiry, Manufacturer.Manufacturer_Name, InvoiceDetail.SalePrice,  
 Items.ReportingUnit, Items.ReportingUOM   
end
