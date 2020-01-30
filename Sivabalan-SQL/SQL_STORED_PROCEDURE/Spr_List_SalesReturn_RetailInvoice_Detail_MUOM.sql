CREATE procedure [dbo].[Spr_List_SalesReturn_RetailInvoice_Detail_MUOM] (@InvoiceID int, @UOMDesc nvarchar(30))  
As  
Select InvoiceDetail.Product_Code,  
"Item Code" = InvoiceDetail.Product_Code,  
"Item Name" = Items.ProductName,  
"Batch" = InvoiceDetail.Batch_Number,  
"PKD" =  Batch_Products.PKD,  
"Expiry" = Batch_Products.Expiry,  
"Quantity" = Cast((    
   				Case When @UOMdesc = 'UOM1' then dbo.sp_Get_ReportingQty(0 - Sum(InvoiceDetail.Quantity), Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)      
       			When @UOMdesc = 'UOM2' then dbo.sp_Get_ReportingQty(0 - Sum(InvoiceDetail.Quantity), Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)      
     			Else dbo.sp_Get_ReportingQty(0 - Sum(InvoiceDetail.Quantity),1)      
   			End) as nvarchar)  
  + ' ' + Cast((    
   			Case When @UOMdesc = 'UOM1' then (SELECT Description FROM UOM WHERE UOM = Items.UOM1)      
       		When @UOMdesc = 'UOM2' then (SELECT Description FROM UOM WHERE UOM = Items.UOM2)      
     		Else (SELECT Description FROM UOM WHERE UOM = Items.UOM)      
   			End) as nvarchar),
"SalePrice" = Cast((    
   				Case When @UOMdesc = 'UOM1' then InvoiceDetail.SalePrice * (Case When IsNull(Items.UOM1_Conversion, 0) = 0 Then 1 Else Items.UOM1_Conversion End)      
       			When @UOMdesc = 'UOM2' then InvoiceDetail.SalePrice * (Case When IsNull(Items.UOM2_Conversion, 0) = 0 Then 1 Else Items.UOM2_Conversion End)      
     			Else InvoiceDetail.SalePrice      
   				End) as nvarchar),  
"Tax Suffered%" = IsNull(Max(InvoiceDetail.TaxSuffered), 0),  
"Discount%" = Sum(InvoiceDetail.DiscountPercentage),  
"Tax Applicable%" = IsNull(Avg(InvoiceDetail.TaxCode), 0) +   
IsNull(Avg(InvoiceDetail.TaxCode2), 0),  
"Amount (%c)" = 0 - Sum(InvoiceDetail.Amount)  
From InvoiceDetail, Items, Batch_Products  
Where InvoiceDetail.Product_Code = Items.Product_Code And  
InvoiceDetail.InvoiceID = @InvoiceID And  
InvoiceDetail.Batch_Code *= Batch_Products.Batch_Code 

Group By InvoiceDetail.Product_Code, Items.ProductName,   
InvoiceDetail.Batch_Number,  
Batch_Products.PKD,
Batch_Products.Expiry,  
InvoiceDetail.SalePrice,
Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2,Items.UOM
