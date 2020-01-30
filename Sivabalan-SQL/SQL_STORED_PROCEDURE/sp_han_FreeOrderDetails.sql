Create Procedure sp_han_FreeOrderDetails (@OrderNumber as nvarchar(50), @Order_Detail_Id as int)  
as  
Select SD.[ORDERNUMBER], SD.[FreeProductCode], SD.[FreeItemQty] "FQty"
,IsNull(u.[UOM], 0) 'UOM_ID', IsNull(u.[Description], '') 'UOM_Desc'          
,IsNull(i.Product_Code, '') 'Item_Code'          
,IsNull(i.UOM, 0) 'Item_UOM'          
,IsNull(i.UOM1, 0) 'Item_UOM1'          
,IsNull(i.UOM2, 0) 'Item_UOM2'          
,IsNull(i.TrackPKD, 0) 'Item_TrackPKD'           
,IsNull(i.CategoryID, 0) 'Item_CategoryID'          
,IsNull(ic.Track_Inventory, 0) 'Item_TrackInventory'          
,IsNull(ic.Price_Option, 0) 'Item_PriceOption'          
,IsNull(batch.Batch_Number, '') 'Batch_Number'          
,IsNull(batch.Item_Code, '') 'Batch_Itemexists'          
,'Item_Converter' = IsNull((Case When u.[UOM] = i.UOM1 Then IsNull(UOM1_Conversion, 1)               
  When u.[UOM] = i.UOM2 Then IsNull(UOM2_Conversion, 1) Else 1 End), 1)               
,[FREE PERCENTAGE] 'Discount'  
,FreeVALUE 'DiscountValue'  
From Scheme_Details SD               
Left Outer Join Items i On i.Product_Code = SD.[FreeProductCode]  
Left Outer Join ItemCategories ic On i.CategoryID = ic.Categoryid   
Left Outer Join UOM u On u.UOM = SD.[FreeitemUOMID]  
Left Outer Join  
 (Select b.Product_Code 'Item_Code', b.Batch_Number, b.SalePrice,  
 IsNull(b.TaxSuffered, 0) TaxSuffered, IsNull(b.ecp , 0) ecp, IsNull(b.PTS,0) PTS,  
 IsNull(b.PTR,0) PTR, IsNull(b.Company_Price,0) Company_Price,  
 IsNull(b.ApplicableOn,0) ApplicableOn, IsNull(b.Partofpercentage,0) Partofpercentage              
 From Batch_Products b              
 Where b.Product_Code in (Select Distinct d.[FreeProductCode] From Scheme_Details d              
     Where d.[ORDERNUMBER] = @OrderNumber)               
 And b.batch_code = (Select top 1 bc.batch_Code     
   From batch_products bc Where  bc.Product_Code = b.Product_Code               
   And bc.Quantity > 0 And IsNull(bc.Damage, 0) = 0               
   And IsNull(bc.Expiry, getdate()) >= getdate()              
   Order By IsNull(bc.Free, 0) desc, bc.Batch_Code)) batch               
On batch.Item_Code = SD.[FreeProductCode]  
Where SD.[ORDERNUMBER] = @OrderNumber and SD.Order_Detail_ID = @Order_Detail_ID   
and Isnull(SD.SchemeID, 0) = 0 and Isnull([FREE PERCENTAGE], 0) = 0 and Isnull(FreeVALUE, 0) = 0
Order by SD.ORDER_DETAIL_ID, SD.OrderNumber, SD.OrderedProductCode
