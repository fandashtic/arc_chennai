CREATE PROCEDURE SP_UPDATE_PRODUCTCODE (@NEWPRODCODE nvarchar(255),@OLDPRODCODE nvarchar(255),@NEWPRODNAME nvarchar(255))              
AS              
declare @open_qty Decimal(18,6)    
declare @open_value Decimal(18,6)    
declare @open_free_qty Decimal(18,6)    
declare @open_damage_qty Decimal(18,6)    
declare @open_damage_value Decimal(18,6)    
declare @free_sal_qty Decimal(18,6)    
declare @tax_value Decimal(18,6)    
declare @open_date datetime    
    
SET NOCOUNT ON             

If rtrim(ltrim(@NEWPRODCODE)) <> rtrim(ltrim(@OLDPRODCODE))
Begin
ALTER TABLE ITEMS NOCHECK CONSTRAINT ALL    
ALTER TABLE BATCH_PRODUCTS NOCHECK CONSTRAINT ALL    
    
if exists(select product_code from items where product_code = @NEWPRODCODE)    
	Begin     
		Declare cItemOpen Cursor For     
		Select Opening_Date , Opening_Quantity , Opening_Value , Free_Opening_Quantity ,     
		Damage_Opening_Quantity , Damage_Opening_Value , Free_Saleable_Quantity, TaxSuffered_Value    
		From openingdetails Where product_code = @OLDPRODCODE    
		OPEN cItemopen     
		FETCH FROM cItemOpen INTO @open_date , @open_qty , @open_value , @open_free_qty ,     
		@open_damage_qty , @open_damage_value , @free_sal_qty , @tax_value    
		While @@fetch_status = 0    
		Begin     
	    	Update OpeningDetails     
	     	set Opening_quantity = Opening_Quantity + @open_qty,     
		    Opening_Value = Opening_Value + @open_value ,     
	    	Free_Opening_Quantity = Free_Opening_Quantity  + @open_free_qty ,     
		    Damage_Opening_Quantity = Damage_Opening_Quantity + @open_damage_qty ,     
		    Damage_Opening_Value = Damage_Opening_Value + @open_damage_value ,     
	    	Free_Saleable_Quantity = Free_Saleable_Quantity + @free_sal_qty ,     
		    TaxSuffered_Value = TaxSuffered_Value + @tax_value      
	    	Where product_code = @NEWPRODCODE and opening_date = @open_date    
	        
		    Fetch Next From cItemOpen into @open_date , @open_qty , @open_value , @open_free_qty ,     
	    	@open_damage_qty , @open_damage_value , @free_sal_qty , @tax_value    
		End     
		CLOSE cItemOpen    
		DEALLOCATE cItemOpen    
	    delete from openingdetails where product_code = @OLDPRODCODE     
	    delete from items where product_code = @OLDPRODCODE    
	End     
 Else  
	Begin  
		update items set Product_Code = @NEWPRODCODE , ProductName = @NEWPRODNAME ,Alias = @NEWPRODCODE where Product_Code = @OLDPRODCODE              
		update OpeningDetails set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE                
	End  
 If Exists(Select Name From Sysobjects Where Name = 'Batch_Products' and Xtype = 'U') 
	update batch_products set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE            
 If Exists(Select Name From Sysobjects Where Name = 'invoicedetail' and Xtype = 'U' )
 	update invoicedetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE             
 If Exists(Select Name From Sysobjects Where Name = 'dispatchdetail' and Xtype = 'U' )
	update dispatchdetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE            
 If Exists(Select Name From Sysobjects Where Name = 'podetail' and Xtype = 'U' )
 	update podetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE              
 If Exists(Select Name From Sysobjects Where Name = 'sodetail' and Xtype = 'U' )
 	update sodetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE              
 If Exists(Select Name From Sysobjects Where Name = 'grndetail' and Xtype = 'U' )
 	update grndetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE              
 If Exists(Select Name From Sysobjects Where Name = 'claimsdetail' and Xtype = 'U' )
 	update claimsdetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE              
 If Exists(Select Name From Sysobjects Where Name = 'billdetail' and Xtype = 'U' )
 	update billdetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE              
 If Exists(Select Name From Sysobjects Where Name = 'stocktransferindetail' and Xtype = 'U' ) 
	update stocktransferindetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE     
 If Exists(Select Name From Sysobjects Where Name = 'stocktransferoutdetail' and Xtype = 'U' )
 	update stocktransferoutdetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE    
 If Exists(Select Name From Sysobjects Where Name = 'adjustmentreturndetail' and Xtype = 'U' )
 	update adjustmentreturndetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE    
 If Exists(Select Name From Sysobjects Where Name = 'stockadjustment' and Xtype = 'U' )
 	update stockadjustment set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE           
 If Exists(Select Name From Sysobjects Where Name = 'StockTransferOutDetailReceived' and Xtype = 'U' )
 	update StockTransferOutDetailReceived set Product_Code = @NEWPRODCODE,ForumCode = @NEWPRODCODE where Product_Code = @OLDPRODCODE              
 If Exists(Select Name From Sysobjects Where Name = 'ClaimsDetailReceived' and Xtype = 'U' )
 	update ClaimsDetailReceived set Product_Code = @NEWPRODCODE,ForumCode = @NEWPRODCODE  where Product_Code = @OLDPRODCODE      
 If Exists(Select Name From Sysobjects Where Name = 'Stock_Request_Detail' and Xtype = 'U' )
 	update Stock_Request_Detail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE      
 If Exists(Select Name From Sysobjects Where Name = 'StockDestructionDetail' and Xtype = 'U' )
 	update StockDestructionDetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE    
 If Exists(Select Name From Sysobjects Where Name = 'VanStatementDetail' and Xtype = 'U' )
 	update VanStatementDetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE        
 If Exists(Select Name From Sysobjects Where Name = 'ItemsReceivedDetail' and Xtype = 'U' )
 	update ItemsReceivedDetail set Product_Code = @NEWPRODCODE, ForumCode = @NEWPRODCODE where Product_Code = @OLDPRODCODE       
 If Exists(Select Name From Sysobjects Where Name = 'InvoiceDetailReceived' and Xtype = 'U' )
 	update InvoiceDetailReceived set Product_Code = @NEWPRODCODE, ForumCode = @NEWPRODCODE  where Product_Code = @OLDPRODCODE     
 If Exists(Select Name From Sysobjects Where Name = 'PODetailReceived' and Xtype = 'U' )
 	update PODetailReceived set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE          
 If Exists(Select Name From Sysobjects Where Name = 'SODetailReceived' and Xtype = 'U' )
 	update SODetailReceived set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE          
 If Exists(Select Name From Sysobjects Where Name = 'AdjustmentReturnDetail_Received' and Xtype = 'U' )
 	update AdjustmentReturnDetail_Received set Product_Code = @NEWPRODCODE, ForumCode = @NEWPRODCODE  where Product_Code = @OLDPRODCODE              
 If Exists(Select Name From Sysobjects Where Name = 'BillTaxComponents' and Xtype = 'U' )
 	update BillTaxComponents set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE         
 If Exists(Select Name From Sysobjects Where Name = 'InvoiceTaxComponents' and Xtype = 'U' )
 	update InvoiceTaxComponents set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE      
 If Exists(Select Name From Sysobjects Where Name = 'STITaxComponents' and Xtype = 'U' )
 	update STITaxComponents set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE          
 If Exists(Select Name From Sysobjects Where Name = 'STOTaxComponents' and Xtype = 'U' )
 	update STOTaxComponents set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE               
 If Exists(Select Name From Sysobjects Where Name = 'itemschemes' and Xtype = 'U' )
 	update itemschemes set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE              
 If Exists(Select Name From Sysobjects Where Name = 'ItemSchemes_Rec' and Xtype = 'U' )
 	update ItemSchemes_Rec set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE           
 If Exists(Select Name From Sysobjects Where Name = 'Item_Properties' and Xtype = 'U' )
 	update Item_Properties set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE           
 If Exists(Select Name From Sysobjects Where Name = 'Special_Cat_Product' and Xtype = 'U' )
 	update Special_Cat_Product set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE       
 If Exists(Select Name From Sysobjects Where Name = 'ItemClosingStock' and Xtype = 'U' )
 	update ItemClosingStock set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE          
 If Exists(Select Name From Sysobjects Where Name = 'Stock_Request_Detail_Received' and Xtype = 'U' )
 	update Stock_Request_Detail_Received set Product_Code = @NEWPRODCODE, ForumCode = @NEWPRODCODE  where Product_Code = @OLDPRODCODE              
 If Exists(Select Name From Sysobjects Where Name = 'CatalogDetail' and Xtype = 'U' )
 	update CatalogDetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE             
 If Exists(Select Name From Sysobjects Where Name = 'SchemeSale' and Xtype = 'U' )
 	update SchemeSale set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE              
 If Exists(Select Name From Sysobjects Where Name = 'ConversionDetail' and Xtype = 'U' )
 	update ConversionDetail set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE          
 If Exists(Select Name From Sysobjects Where Name = 'ForeCast' and Xtype = 'U' )
 	update ForeCast set Product_Code = @NEWPRODCODE where Product_Code = @OLDPRODCODE                  
 If Exists(Select Name From Sysobjects Where Name = 'downloadeditems' and Xtype = 'U' )
 	update downloadeditems  set Product_Id = @NEWPRODCODE where Product_Id = @OLDPRODCODE              
 If Exists(Select Name From Sysobjects Where Name = 'schemeitems' and Xtype = 'U' )
 	update schemeitems set freeitem = @NEWPRODCODE where freeitem = @OLDPRODCODE               
 If Exists(Select Name From Sysobjects Where Name = 'schemeitems_rec' and Xtype = 'U' )
 	update schemeitems_rec set freeitem = @NEWPRODCODE where freeitem = @OLDPRODCODE               
  
--  If Exists(select product_code from items where product_code = @NEWPRODCODE)    
--  Begin     
-- 	Delete from openingdetails where product_code = @OLDPRODCODE     
-- 	Delete from items where product_code = @OLDPRODCODE    
--  End  
 ALTER TABLE ITEMS CHECK CONSTRAINT ALL    
 ALTER TABLE BATCH_PRODUCTS CHECK CONSTRAINT ALL    
                  
End
SET NOCOUNT OFF    




