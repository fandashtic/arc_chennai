CREATE PROCEDURE sp_cancel_salesreturn_invoice      
	  	(@InvoiceId int)      
AS      
DECLARE @ItemCode Nvarchar(15)
DECLARE @Batch_Code Int      
DECLARE @Quantity Decimal(18,6)      
DECLARE @InvoiceDate DateTime
DECLARE @LOCALITY Int
DECLARE @IS_VAT_ITEM Int
DECLARE @STATUS Int 
DECLARE @DOCSERIAL nvarchar(10)
Declare @BATCHNUMBER nVarchar(128)
DECLARE @CNT Int 
DECLARE @SALEPRICE Decimal(18,6)
DECLARE @INVPREFIX nVarChar(20)
Declare @CUSTOMERCATEGORY Int
Set @STATUS = 0 
SET @DOCSERIAL = 0 
select @INVPREFIX = Prefix from Voucherprefix where TranID = 'INVOICE'
Select @InvoiceDate=InvoiceDate from InvoiceAbstract Where InvoiceID=@InvoiceId
Select @LOCALITY = IsNull(Locality, 0),  @STATUS = ISNULL(Status, 0), @DOCSERIAL = IsNull(Replace(ReferenceNumber,@INVPREFIX,N''),0)
From InvoiceAbstract, Customer Where InvoiceAbstract.CustomerID = Customer.CustomerID And InvoiceID = @InvoiceId 
Select @CUSTOMERCATEGORY = CustomerCategory From Customer, InvoiceAbstract Where Customer.CustomerID = InvoiceAbstract.CustomerID And InvoiceAbstract.InvoiceID = @InvoiceId
DECLARE GetReturnedInvoice CURSOR STATIC FOR
Select Product_Code, Batch_Code, Quantity, IsNull(Batch_Number,''), IsNull(SalePrice,0) from InvoiceDetail where InvoiceId = @InvoiceId      
OPEN GetReturnedInvoice      
FETCH FROM GetReturnedInvoice INTO  @ItemCode, @Batch_Code, @Quantity, @BATCHNUMBER, @SALEPRICE    
WHILE @@FETCH_STATUS = 0      
BEGIN      
	If @Batch_Code > 0  
	  Begin  
		If Exists (Select * from Batch_Products Where Batch_Code=@Batch_Code And DocType=3 And DocId=@InvoiceId)
		Begin	
			--Updating TaxSuff Percentage in OpeningDetails
			Select @IS_VAT_ITEM=IsNull(Vat,0) From Items Where Product_Code=@ItemCode
			If Exists (Select * From SysColumns Where Name = 'PTS' And ID = (Select ID From Sysobjects Where Name = 'Items'))  
				If @LOCALITY = 2 AND @IS_VAT_ITEM = 1
					Exec Sp_Update_Opening_TaxSuffered_Percentage @InvoiceDate, @ItemCode, @Batch_Code, 1, 1
				Else
					Exec Sp_Update_Opening_TaxSuffered_Percentage @InvoiceDate, @ItemCode, @Batch_Code, 1	
			Else
				If @LOCALITY = 2 AND @IS_VAT_ITEM = 1
					Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @InvoiceDate, @ItemCode, @Batch_Code, 1, 1	
				Else
					Exec Sp_Update_Opening_TaxSuffered_Percentage_FMCG @InvoiceDate, @ItemCode, @Batch_Code, 1	
		End
		
		IF (@STATUS & 32) = 32
		BEGIN
			UPDATE batch_products set Quantity = Quantity - @Quantity, QuantityReceived = QuantityReceived - @Quantity
			Where Batch_Code = @Batch_Code and (Quantity - @Quantity) >= 0      
			IF @@ROWCOUNT = 0       
			BEGIN      
			SELECT 0      
			GOTO OVERNOUT       
	  		END  
		END      
		ELSE
		BEGIN
			UPDATE batch_products set Quantity = Quantity - @Quantity
			Where Batch_Code = @Batch_Code and (Quantity - @Quantity) >= 0      
			IF @@ROWCOUNT = 0       
			BEGIN      
			SELECT 0      
			GOTO OVERNOUT       
	  		END  
		END    		

	End  
	FETCH NEXT FROM GetReturnedInvoice INTO  @ItemCode, @Batch_Code , @Quantity, @BATCHNUMBER, @SALEPRICE       
END
UPDATE InvoiceAbstract Set CancelDate = Getdate(), Status = InvoiceAbstract.Status | 192, Balance = 0      
Where InvoiceID = @InvoiceID
SELECT 1       
OVERNOUT:      
CLOSE GetReturnedInvoice      
DEALLOCATE GetReturnedInvoice      
    
If exists (select * from sysobjects where xtype = 'u' and name = 'tbl_mERP_OutletPoints')  
	update tbl_mERP_OutletPoints set Status = 1 where invoiceid = @InvoiceId

