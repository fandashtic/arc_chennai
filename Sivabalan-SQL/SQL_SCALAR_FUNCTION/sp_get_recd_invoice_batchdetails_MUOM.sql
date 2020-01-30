CREATE FUNCTION sp_get_recd_invoice_batchdetails_MUOM(@INVOICE int,  
       @PRODUCT_CODE nvarchar(15),  
       @PRICE_OPTION int,  
       @PTS Decimal(18,6),  
       @PTR Decimal(18,6),  
       @ECP Decimal(18,6),  
       @BATCH nvarchar(128),  
       @EXPIRY datetime,  
       @PKD datetime,  
       @FUNCTION int = 0,  
       @LOCALITY int = 1,
       @UOM int = 0)  
RETURNS Decimal(18,6)  
AS  
Begin  
	DECLARE @SalePrice Decimal(18,6)  
	IF @FUNCTION = 0  
	Begin  
		IF @PRICE_OPTION = 1  
		Begin  
			Select @SalePrice = UOMPrice From InvoiceDetailReceived  
				Where  InvoiceID = @INVOICE And Product_Code = @PRODUCT_CODE And  
				PTS = @PTS And PTR = @PTR And MRP = @ECP And Batch_Number = @BATCH And  
				((Expiry = @EXPIRY And @EXPIRY Is Not Null) Or @EXPIRY Is Null) And  
				((PKD = @PKD And @PKD Is Not Null) Or @PKD Is Null) And
				((UOM = @UOM AND UOM <> 0) Or (UOM = 0))
		End  
		Else  
		Begin  
			Select @SalePrice = UOMPrice From InvoiceDetailReceived  
				Where  InvoiceID = @INVOICE And Product_Code = @PRODUCT_CODE And  
				IsNull(Batch_Number, N'') = IsNull(@BATCH, N'') And  
				((Expiry = @EXPIRY And @EXPIRY Is Not Null) Or @EXPIRY Is Null) And  
				((PKD = @PKD And @PKD Is Not Null) Or @PKD Is Null) And  
				SalePrice > 0  
		End  
	End  
	Else If @Function = 1  
	Begin  
		IF @PRICE_OPTION = 1  
		Begin  
			Select @SalePrice = (Case InvoiceDetailReceived.TaxCode   
				When 0 Then 0   
				Else (Case @Locality When 1 Then   
				(Select max(Percentage) From Tax Where Percentage = InvoiceDetailReceived.TaxCode)   
				Else  
				(Select max(CST_Percentage) From Tax Where CST_Percentage = InvoiceDetailReceived.TaxCode)   
				End) End)  
				From InvoiceDetailReceived  
				Where  InvoiceID = @INVOICE And Product_Code = @PRODUCT_CODE And  
				PTS = @PTS And PTR = @PTR And MRP = @ECP And Batch_Number = @BATCH And  
				((Expiry = @EXPIRY And @EXPIRY Is Not Null) Or @EXPIRY Is Null) And  
				((PKD = @PKD And @PKD Is Not Null) Or @PKD Is Null)  
		End  
		Else  
		Begin  
			Select @SalePrice = (Case InvoiceDetailReceived.TaxCode   
				When 0 Then 0   
				Else (Case @Locality When 1 Then   
				(Select max(Percentage) From Tax Where Percentage = InvoiceDetailReceived.TaxCode)   
				Else  
				(Select max(CST_Percentage) From Tax Where CST_Percentage = InvoiceDetailReceived.TaxCode)   
				End) End)  
				From InvoiceDetailReceived  
				Where  InvoiceID = @INVOICE And Product_Code = @PRODUCT_CODE And  
				Batch_Number = @BATCH And  
				((Expiry = @EXPIRY And @EXPIRY Is Not Null) Or @EXPIRY Is Null) And  
				((PKD = @PKD And @PKD Is Not Null) Or @PKD Is Null)  
				And SalePrice > 0  
		End  
	End  
	Else  
	Begin  
		Select @SalePrice = Case When (Sum(UOMQty * UOMPrice) = 0) 
			Then 0 
			Else (Sum(DiscountValue) / Sum(UOMQty * UOMPrice)) * 100 End 
			From InvoiceDetailReceived IDR, Items  
			Where InvoiceID = @INVOICE And IDR.Product_Code = @PRODUCT_CODE And  
			((IDR.Batch_Number = @BATCH and @BATCH <> '') or @BATCH = '')And  
			((Expiry = @EXPIRY And @EXPIRY Is Not Null) Or @EXPIRY Is Null) And  
			((PKD = @PKD And @PKD Is Not Null) Or @PKD Is Null) And  
-- 			IsNull(IDR.PTS, 0) = IsNull(@PTS, 0) And IsNull(IDR.PTR, 0) = IsNull(@PTR, 0) And   
-- 			IsNull(IDR.MRP, 0) = IsNull(@ECP, 0) And 
			Items.Product_Code = IDR.Product_Code And
			((IDR.UOM = @UOM and ISNULL(IDR.UOM,0) <> 0) Or (ISNULL(IDR.UOM,0) = 0 and @UOM = ITEMS.UOM))
	End  
	RETURN @SalePrice  
End
