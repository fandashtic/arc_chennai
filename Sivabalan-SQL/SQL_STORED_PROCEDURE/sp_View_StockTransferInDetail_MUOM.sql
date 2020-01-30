create Procedure sp_View_StockTransferInDetail_MUOM(@DocSerial int)        
As        
 Select StockTransferInDetail.Product_Code, Items.ProductName, Batch_Number,  
  "PTS"= Case         
   When IsNull(ItemCategories.Price_Option, 0) = 0 And Items.Virtual_Track_Batches = 0 And Items.TrackPKD = 0 Then        
    Items.PTS        
   Else        
    StockTransferInDetail.PTS        
   End,  
  "PTR"= Case         
   When IsNull(ItemCategories.Price_Option, 0) = 0 And Items.Virtual_Track_Batches = 0 And Items.TrackPKD = 0 Then        
    Items.PTR        
   Else        
    StockTransferInDetail.PTR        
   End,  
  "ECP"= case         
   When IsNull(ItemCategories.Price_Option, 0) = 0 And Items.Virtual_Track_Batches = 0 And Items.TrackPKD = 0 Then        
    Items.ECP        
   Else        
    StockTransferInDetail.ECP        
   End,  
  "Special Price"= Case         
   When IsNull(ItemCategories.Price_Option, 0) = 0 And Items.Virtual_Track_Batches = 0 And Items.TrackPKD = 0 Then        
    Items.Company_Price        
   Else        
    StockTransferInDetail.SpecialPrice        
   End,   
  "Rate"=StockTransferInDetail.Rate,         
  "Quantity"=StockTransferInDetail.Quantity,   
  "Amount"=StockTransferInDetail.Amount,   
  "Expiry"=StockTransferInDetail.Expiry,         
  "PKD"=StockTransferInDetail.PKD,  
  "Tax Suffered"= StockTransferInDetail.TaxSuffered,         
  "TaxAmount"=StockTransferInDetail.TaxAmount,   
  "Total"=StockTransferInDetail.TotalAmount,  
  StockTransferInDetail.UOM as UOMID,   
  StockTransferInDetail.Promotion,   
  StockTransferInDetail.TaxCode,   
  StockTransferInDetail.Serial,  
  StockTransferInDetail.UOMPrice,  
  StockTransferInDetail.UOM as uomid,  
  StockTransferInDetail.DocumentQuantity,  
  StockTransferInDetail.DocumentFreeQty,  
  StockTransferInDetail.QuantityReceived,  
  StockTransferInDetail.QuantityRejected,
  "PFM"= Case         
   When IsNull(ItemCategories.Price_Option, 0) = 0 And Items.Virtual_Track_Batches = 0 And Items.TrackPKD = 0 Then        
    Items.PFM        
   Else        
    StockTransferInDetail.PFM        
   End    ,StockTransferInDetail.MRPFORTAX,isnull(StockTransferInDetail.TOQ,0) as TOQ 
, "HSNNumber" = StockTransferInDetail.HSNNumber, "CS_TaxCode" = StockTransferInDetail.CS_TaxCode
,"TaxTypeID" = Case When STA.GSTFlag = 0 Then STA.TaxType 
							   Else Case When IsNull(StockTransferInDetail.TaxType,0) = 5  Then 
							   Case When IsNull(StockTransferInDetail.GSTTaxType,0) = 1 Then 5 Else 6 End  
							   When IsNull(StockTransferInDetail.TaxType,0) = 0 And  IsNull(StockTransferInDetail.CS_TaxCode ,0) > 0 
							   Then 5 Else IsNull(StockTransferInDetail.TaxType,1) End
							  End 
					--Case when isnull(StockTransferInDetail.TaxType,0) = 0 then (select top 1 TaxType from StockTransferInAbstract where DocSerial = StockTransferInDetail.DocSerial)
					--Else isnull(StockTransferInDetail.TaxType,0) End
, "TaxType" = Case When STA.GSTFlag = 0 
							Then (Select Top 1 T.Taxtype From tbl_mERP_Taxtype T Where T.TaxID = STA.TaxType ) 
					Else Case When IsNull(StockTransferInDetail.TaxType,0) = 5 Then 
									Case when IsNull(StockTransferInDetail.GSTTaxType,0) = 1 Then 'Intra State' Else 'Inter state' End
							  When IsNull(StockTransferInDetail.TaxType,0) = 0 And  IsNull(StockTransferInDetail.CS_TaxCode ,0) > 0 Then  'Intra State'  
							  Else (Select Top 1 T.Taxtype From tbl_mERP_Taxtype T Where T.TaxID = IsNull(StockTransferInDetail.TaxType,1))  End
					End

--Case when isnull(StockTransferInDetail.TaxType,0) = 5 Then Case When Isnull(StockTransferInDetail.GSTTaxType,0) = 1 Then 'Intra State' Else 'Inter state' End 
--							When isnull(StockTransferInDetail.TaxType,0) = 0 And isnull(StockTransferInDetail.CS_TaxCode ,0) > 0 Then 'Intra State' 
--							When 							
--					Case when (isnull(StockTransferInDetail.TaxType,0) = 5 and Isnull(StockTransferInDetail.GSTTaxType,0) = 1) then 'Intra State'
--				   when  (isnull(StockTransferInDetail.TaxType,0) = 5 and Isnull(StockTransferInDetail.GSTTaxType,0) = 2) then 'Inter state'
--				   when isnull(StockTransferInDetail.TaxType,0) = 0 And isnull(StockTransferInDetail.CS_TaxCode ,0) > 0   then 'Intra State' 
--				   When isnull(StockTransferInDetail.TaxType,0) = 0 And isnull(StockTransferInDetail.CS_TaxCode ,0) = 0 
--				   then 
--				   Else (select top 1 T.TaxType from StockTransferInAbstract A,tbl_mERP_Taxtype T  where A.DocSerial = StockTransferInDetail.DocSerial and T.TaxID =A.Taxtype And T.TaxID <> 5 )					   
--				   Else (select Distinct TaxType from tbl_mERP_ALLTaxtype where TaxID = isnull(StockTransferInDetail.TaxType,1))
--				   End	
,"GSTTaxType" = isnull(StockTransferInDetail.GSTTaxType ,0)	 		   
 From StockTransferInDetail, Items, ItemCategories, StockTransferInAbstract STA        
 Where STA.DocSerial = @DocSerial And StockTransferInDetail.DocSerial = STA.DocSerial And
 StockTransferInDetail.DocSerial = @DocSerial And        
 StockTransferInDetail.Product_Code = Items.Product_Code And        
 Items.CategoryID = ItemCategories.CategoryID And  
 (StockTransferInDetail.QuantityReceived-StockTransferInDetail.QuantityRejected > 0 Or  
 StockTransferInDetail.Quantity > 0)       
 Order By  StockTransferInDetail.Serial Asc
  
