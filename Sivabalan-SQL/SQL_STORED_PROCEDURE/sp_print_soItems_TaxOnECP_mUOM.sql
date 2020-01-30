Create PROCEDURE sp_print_soItems_TaxOnECP_mUOM (@SONumber int)          
AS          
SELECT "Item Code" = Max(SODetail.Product_Code), "Item Name" = Max(ProductName),   
 "Quantity" = Sum(UOMQTY),   
 "Sale Price" = Avg(UOMPRICE),   
 "Tax" = ISNULL(Max(SaleTax), 0) + ISNULL(Max(TaxCode2), 0),   
 "Discount" = Avg(Discount),   
 "UOM" = dbo.fn_GetUOMDesc(SoDetail.UOM,0),   
 "Pending" = Sum(IsNull(Pending,0)) / Case When SODetail.UOM = Items.UOM1 Then UOM1_Conversion When SODetail.UOM = Items.UOM2 Then UOM2_Conversion Else 1 End,     
 "Tax Suffered" = ISNULL(Max(SODetail.TaxSuffered), 0),    
 "Description" = Max(Isnull(Items.Description,N'')),   
 "Item Gross Value" = Sum(quantity * SalePrice),   
 "Invoice Gross Value" = IsNull(dbo.GetInvoiceGrossValueFromSC(@SONumber, Max(SODetail.Product_Code)),0),    
 "Total Tax Amount"=Round(  
         Sum(  
          (  
           (  
           (SODetail.Quantity * SODetail.SalePrice) - ((SODetail.Quantity * SODetail.SalePrice) * SODetail.Discount / 100))    
           *(IsNull(SODetail.TaxSuffered,0) + Isnull(SODetail.SaleTax,0) + Isnull(SODetail.TaxCode2,0)  
            )/100  
          )  
          )  
        ,2),    
"ECP"=Max(SODETAIL.ECP), "Batch" = Max(SODetail.Batch_Number),"UOMID"= Max(SoDetail.UOM),   
"PriceOption" = Max(ItemCategories.Price_Option),"TrackBatch"= Max(Items.Track_Batches),    
"OriginalSalePrice"=Max(Sodetail.SalePrice),    
"VAT" = Max(isnull(sodetail.vat,0)),    
"TaxApplicableon" = Max(isnull(sodetail.taxapplicableon,0)),    
"TaxPartOff" = Max(isnull(sodetail.taxpartoff,0)),    
"TaxSuffApplicableon" = Max(isnull(sodetail.taxSuffapplicableon,0)),    
"TaxsuffPartOff" = Max(isnull(sodetail.taxsuffpartoff,0)),    
"PTS"=Case When Max(SODETAIL.PTS) Is NULL Then Max(Items.PTS) Else Max(SODETAIL.PTS) End,
"MRPPERPACK"=Case When Max(SODETAIL.MRPPERPACK) Is NULL Then Max(Items.MRPPERPACK) Else Max(SODETAIL.MRPPERPACK) End,
"TOQ" = Max(Isnull(SoDetail.TaxonQty,0))
FROM SODetail
Inner Join Items On SODetail.Product_Code = Items.Product_Code           
Left Outer Join UOM On SODETAIL.UOM = UOM.UOM    
Inner Join ItemCategories On Items.CategoryID = ItemCategories.CategoryID       
WHERE SODetail.SONumber = @SONumber           
group by Sodetail.Serial, SODetail.UOM,Items.UOM1_Conversion,Items.UOM2_Conversion,Items.UOM1,Items.UOM2  
order by Sodetail.Serial
