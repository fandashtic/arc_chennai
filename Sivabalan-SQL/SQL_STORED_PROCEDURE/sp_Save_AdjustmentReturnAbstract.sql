CREATE Procedure sp_Save_AdjustmentReturnAbstract        
(@BILLID INT,@ADJUSTMENTDATE DATETIME , @VENDORID NVARCHAR (15), @VALUE Decimal(18,6),    
 @Total_Value Decimal(18,6), @Reference nVarchar(128) = NULL, @TaxOnMRP INT = NULL,    
 @VATTaxAmount Decimal(18,6) =0, @UserName nvarchar(100) = NULL
 ,@GSTFlag Int=0,@FromStatecode Int = 0,@ToStatecode Int = 0,@GSTIN nVarChar(15) = '' 
 ,@OperatingYear nvarchar(10) = '')
AS        
DECLARE @DocumentID int        
DECLARE @GSTDocumentID int        
Declare @GSTVoucherPrefix nVarChar(10)
Declare @GSTFullDocID nVarChar(255)
Declare @Year as nvarchar(20)

Select @Year = Cast(Substring(@OperatingYear,3,3) as nvarchar) + Cast(Substring(@OperatingYear,8,2) as nvarchar)

BEGIN TRAN        
UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 9        
SELECT @DocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 9        
--GST 
if @GSTFlag = 1
Begin

--	UPDATE DocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 103
--	SELECT @GSTDocumentID = DocumentID - 1 FROM DocumentNumbers WHERE DocType = 103        
--	Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'GST_PURCHASE_RETURN'
--	Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocumentID as nvarchar)

	UPDATE GSTDocumentNumbers SET DocumentID = DocumentID + 1 WHERE DocType = 103 and OperatingYear = @OperatingYear
	SELECT @GSTDocumentID = DocumentID - 1 FROM GSTDocumentNumbers WHERE DocType = 103  and OperatingYear = @OperatingYear      
	Select @GSTVoucherPrefix = Prefix From VoucherPrefix Where TranID = 'GST_PURCHASE_RETURN'
	Select @GSTFullDocID = @GSTVoucherPrefix + '/' + @Year + '/' + Cast(@GSTDocumentID as nvarchar)

End
COMMIT TRAN        
        
Insert into AdjustmentReturnAbstract(BillID,AdjustmentDate,VendorID, DocumentID, Value, Balance, Total_Value, Reference, 
	TaxOnMRP,VATTaxAmount, UserName,GSTFlag,FromStatecode,ToStatecode,GSTIN,GSTDocID,GSTFullDocID)
values(@BILLID,@ADJUSTMENTDATE,@VENDORID, @DocumentID, @VALUE, @Total_Value,  @Total_Value, @Reference,
	@TaxOnMRP,@VATTaxAmount, @UserName, @GSTFlag, @FromStatecode, @ToStatecode, @GSTIN,@GSTDocumentID,@GSTFullDocID)        
Select @@Identity, @DocumentID        

