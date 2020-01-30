
CREATE FUNCTION sp_get_recd_invoice_batchdetails(@INVOICE int,      
       @PRODUCT_CODE nvarchar(15),      
       @PRICE_OPTION int,      
       @PTS Decimal(18,6),      
       @PTR Decimal(18,6),      
       @ECP Decimal(18,6),      
       @BATCH nvarchar(128),      
       @EXPIRY datetime,      
       @PKD datetime,      
       @FUNCTION int = 0,      
       @LOCALITY int = 1)      
RETURNS Decimal(18,6)      
AS      
Begin      
DECLARE @SalePrice Decimal(18,6)      
Set @SalePrice = 0

IF @FUNCTION = 0      
Begin      
 IF @PRICE_OPTION = 1      
 Begin      
 Select @SalePrice = SalePrice From InvoiceDetailReceived      
 Where  InvoiceID = @INVOICE And Product_Code = @PRODUCT_CODE And      
  PTS = @PTS And PTR = @PTR And MRP = @ECP And Batch_Number = @BATCH And      
  ((Expiry = @EXPIRY And @EXPIRY Is Not Null) Or @EXPIRY Is Null) And      
  ((PKD = @PKD And @PKD Is Not Null) Or @PKD Is Null)      
 End      
 Else      
 Begin      
 Select Top 1 @SalePrice = SalePrice From InvoiceDetailReceived      
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
		(Select Top 1 Percentage From Tax Where Percentage = InvoiceDetailReceived.TaxCode
		And LSTApplicableOn = IsNull(InvoiceDetailReceived.TaxApplicableOn, 1) 
		And LSTPartOff =IsNull(InvoiceDetailReceived.TaxPartOff, 100))       
		Else      
		(Select Top 1 CST_Percentage From Tax Where CST_Percentage = InvoiceDetailReceived.TaxCode
		And CSTApplicableOn = IsNull(InvoiceDetailReceived.TaxApplicableOn, 1) 
		And CSTPartOff =IsNull(InvoiceDetailReceived.TaxPartOff, 100))              
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
		(Select Top 1 Percentage From Tax Where Percentage = InvoiceDetailReceived.TaxCode
		And LSTApplicableOn = IsNull(InvoiceDetailReceived.TaxApplicableOn, 1) 
		And LSTPartOff =IsNull(InvoiceDetailReceived.TaxPartOff, 100))       
		Else      
		(Select Top 1 CST_Percentage From Tax Where CST_Percentage = InvoiceDetailReceived.TaxCode
		And CSTApplicableOn = IsNull(InvoiceDetailReceived.TaxApplicableOn, 1) 
		And CSTPartOff =IsNull(InvoiceDetailReceived.TaxPartOff, 100))              
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
 Select @SalePrice = (Sum(DiscountValue) / Sum((Quantity * SalePrice))) * 100  From InvoiceDetailReceived      
 Where InvoiceID = @INVOICE And Product_Code = @PRODUCT_CODE And      
 Batch_Number = @BATCH And      
 ((Expiry = @EXPIRY And @EXPIRY Is Not Null) Or @EXPIRY Is Null) And      
 ((PKD = @PKD And @PKD Is Not Null) Or @PKD Is Null) And      
 IsNull(PTS, 0) = IsNull(@PTS, 0) And IsNull(PTR, 0) = IsNull(@PTR, 0) And       
 IsNull(MRP, 0) = IsNull(@ECP, 0) And
 SalePrice > 0 
End      
RETURN @SalePrice      
End      

