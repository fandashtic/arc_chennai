Create Procedure sp_han_GetOrderDetail (@OrderNumber as nVarchar(50), @SalesmanID as Int)
As   
Declare @Locality As Int
Declare @GroupID as nvarchar(200)
Select @Locality = Locality From Customer           
Where CustomerID = (Select Top 1 OutletID From Order_Header Where ORDERNUMBER = @OrderNumber)                      
Set @Locality = IsNull(@Locality, 1)                  

select @GroupID=dbo.fn_han_Get_ItemGroup(@OrderNumber,@SalesmanID)

Create Table #Products(Product_Code nvarchar(255) COLLATE SQL_Latin1_General_CP1_CI_AS)                
Insert into #Products(Product_Code)
Select Product_Code from dbo.sp_Get_Items_ITC(@GroupID)

/* For Performance Tuning*/
--Select *into #BP from batch_products bc where
-- bc.Quantity > 0 And IsNull(bc.Damage, 0) = 0                       
--   And IsNull(bc.Expiry, getdate()) >= getdate()                      
--   Order By IsNull(bc.Free, 0), bc.Batch_Code


--Temp table to accumulate ordered And scheme item                   
Create Table #Ord_Det (OrderNumber nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS
 , ItemID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS                  
 , OrderedQty Decimal(18, 6)
 , UOM nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS                  
 , O_ItemID nVarchar(50) COLLATE SQL_Latin1_General_CP1_CI_AS                  
 , O_OrderedQty Decimal(18, 6)
 , O_UOM nVarchar(15) COLLATE SQL_Latin1_General_CP1_CI_AS                  
 , Flag Integer, ErrFlag Integer          
 , [Det_ID] integer)                  
                  
--Dumb Details of Ordered item                  
Insert Into #Ord_Det           
Select I_OD.OrderNumber                    
  , I_OD.Product_Code 'ItemID', I_OD.OrderedQty 'OrderedQty',I_OD.UOMID 'UOM'                    
  , I_OD.Product_Code 'O_ItemID', I_OD.OrderedQty 'O_OrderedQty', I_OD.UOMID 'O_UOM'                     
  , 1 'Flag', 0 'ErrFlag' -- Function to validate Scheme Details          
  , I_OD.Order_Detail_ID            
  From Order_Details I_OD Where I_OD.[ORDERNUMBER] = @OrderNumber               
          
--Retrieve info                   
Select od.[ORDERNUMBER], od.[ITEMID], od.[ORDEREDQTY] -- od.[UOM] 'Order_UOM_Desc'                        
, u.[Description] 'Order_UOM_Desc'                        
,IsNull(u.[UOM], 0) 'UOM_ID', IsNull(u.[Description], '') 'UOM_Desc'                  
,IsNull(i.Product_Code, '') 'Item_Code'                  
,IsNull(i.UOM, 0) 'Item_UOM'                  
,IsNull(i.UOM1, 0) 'Item_UOM1'                  
,IsNull(i.UOM2, 0) 'Item_UOM2'                  
,IsNull(i.Purchase_Price, 0) 'Item_PurchasePrice'                  
,IsNull(i.Sale_Price, 0) 'Item_Saleprice'                  
,IsNull(i.Sale_Tax, 0) 'Item_SaleTax'                      
,IsNull(i.MRP, 0) 'Item_MRP'                  
,IsNull(i.Company_Price, 0) 'Item_CompanyPrice'                  
,IsNull(i.PTS, 0) 'Item_PTS'                  
,IsNull(i.PTR, 0) 'Item_PTR'                  
,IsNull(i.ECP, 0) 'Item_ECP'                  
,IsNull(i.TaxSuffered, 0) 'Item_TaxSuffered'                  
,IsNull(i.Vat, 0) 'Item_Vat'                  
,IsNull(i.CollectTaxSuffered, 0) 'Item_CollectTaxSuffered'                  
,IsNull(i.Track_Batches, 0) 'Item_Track_Batches'                  
,IsNull(i.TrackPKD, 0) 'Item_TrackPKD'                   
,IsNull(i.CategoryID, 0) 'Item_CategoryID'                  
,IsNull(ic.Track_Inventory, 0) 'Item_TrackInventory'                  
,IsNull(ic.Price_Option, 0) 'Item_PriceOption'   
,'' as 'Batch_Number'
,'' as 'Batch_SalePrice' 
,'' as 'Batch_ecp' 
,'' as 'Batch_PTR' 
,'' as 'Batch_Company_Price' 
,'' as 'Batch_PTS'  
,'' as 'Batch_TaxSuffered' 
,'' as 'Batch_ApplicableOn'
,'' as 'Batch_Partofpercentage' 
,'' as 'Batch_Itemexists'
             
--,IsNull(batch.Batch_Number, '') 'Batch_Number'                  
--,IsNull(batch.SalePrice, 0) 'Batch_SalePrice'                  
--,IsNull(batch.ecp, 0) 'Batch_ecp'                  
--,IsNull(batch.PTR, 0) 'Batch_PTR'                  
--,IsNull(batch.Company_Price, 0) 'Batch_Company_Price'                  
--,IsNull(batch.PTS, 0) 'Batch_PTS'                  
--,IsNull(batch.TaxSuffered, 0) 'Batch_TaxSuffered'                  
--,IsNull(batch.ApplicableOn, 0) 'Batch_ApplicableOn'                  
--,IsNull(batch.Partofpercentage, 0) 'Batch_Partofpercentage'                  
--,IsNull(batch.Item_Code, '') 'Batch_Itemexists'                  
,IsNull((Case @locality When 1 Then stax.Percentage Else stax.CST_Percentage End), 0) 'SaletaxPer'                   
,'SaleTaxApplicableOn' = IsNull((Case @locality When 1 Then stax.LSTApplicableOn Else stax.CSTApplicableOn End), 0)    
,'SaleTaxPartOff' = IsNull((Case @locality When 1 Then stax.LSTPartOff Else stax.CSTPartOff End), 0)                  
, IsNull((Case @locality When 1 Then tstax.Percentage Else tstax.CST_Percentage End), 0) 'TS_taxPer'                  
,'TS_TaxApplicableOn' = IsNull((Case @locality When 1 Then tstax.LSTApplicableOn Else tstax.CSTApplicableOn End), 0)                  
,'TS_TaxPartOff' = IsNull((Case @locality When 1 Then tstax.LSTPartOff Else tstax.CSTPartOff End), 0)                  
,'Item_Converter' = IsNull((Case When u.[UOM] = i.UOM1 Then IsNull(UOM1_Conversion, 1)                       
  When u.[UOM] = i.UOM2 Then IsNull(UOM2_Conversion, 1) Else 1 End), 1)          
,OD.Flag                  
,OD.ErrFlag           
,Isnull((Select Sum(IsNull([FREE PERCENTAGE], 0)) from Scheme_Details S           
	 Where S.Order_Detail_ID = OD.Det_ID and Isnull(S.SchemeID, 0) = 0           
	 and Isnull(S.FreeProductCode, '') = '' and Isnull(FreeItemQty, 0) = 0           
	 and Isnull(FreeitemUOMID, 0) = 0), 0) 'Discount%'          
,Isnull((Select Sum(IsNull([FreeVALUE], 0)) from Scheme_Details S           
	 Where S.Order_Detail_ID = OD.Det_ID and Isnull(S.SchemeID, 0) = 0           
	 and Isnull(S.FreeProductCode, '') = '' and Isnull(FreeItemQty, 0) = 0           
	 and Isnull(FreeitemUOMID, 0) = 0), 0) 'DiscountVALUE'          
,Isnull(OD.Det_ID, 0) 'Det_ID'          
From #Ord_Det OD                       
Inner Join Items i On i.Product_Code = od.[ITEMID]                      
Inner Join ItemCategories ic On i.CategoryID = ic.Categoryid     
Left Outer Join UOM u On u.UOM = od.[UOM]          
Left Outer Join Tax stax On stax.tax_code = i.Sale_Tax                      
Left Outer Join Tax tstax On tstax.tax_code = i.TaxSuffered                      
--Left Outer Join                       
-- (Select b.Product_Code 'Item_Code', b.Batch_Number, b.SalePrice,                      
-- IsNull(b.TaxSuffered, 0) TaxSuffered, IsNull(b.ecp , 0) ecp, IsNull(b.PTS,0) PTS,                       
-- IsNull(b.PTR,0) PTR, IsNull(b.Company_Price,0) Company_Price,                      
-- IsNull(b.ApplicableOn,0) ApplicableOn, IsNull(b.Partofpercentage,0) Partofpercentage                      
-- From #BP b                      
-- Where b.Product_Code in (Select Distinct d.[ItemID] From #Ord_Det d                      
--     Where d.[ORDERNUMBER] = @OrderNumber)                       
-- And b.batch_code = (Select top 1 bc.batch_Code             
--   From #BP bc Where  bc.Product_Code = b.Product_Code                                          
--   Order By IsNull(bc.Free, 0), bc.Batch_Code)) batch                       
--On batch.Item_Code = od.[ITEMID]                      
Where od.[ORDERNUMBER] = @OrderNumber                    
and ((od.[ITEMID] in (Select  Product_Code from #Products) and isnull(@GroupID,'')<> '') Or isnull(@GroupID,'')='')
Order by OD.OrderNumber, OD.O_ItemID, OD.O_OrderedQty, OD.O_UOM, OD.Flag                     

Drop Table #Ord_Det
Drop Table #Products
--Drop Table #BP
