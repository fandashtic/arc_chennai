CREATE Procedure sp_Save_Amend_AdjustmentReturnAbstract              
	(@BILLID INT,@ADJUSTMENTDATE DATETIME , @VENDORID nvarchar (15), @VALUE Decimal(18,6), @Total_Value Decimal(18,6), 
	@DocReference int,@AdjId int,@DocIDRef nvarchar(50), @Reference nvarchar(128) = NULL, @TaxOnMRP INT = NULL, 
	@VATTaxAmount Decimal(18,6) =0, @UserName nvarchar(100) = NULL
	,@GSTFlag Int=0,@FromStatecode Int = 0,@ToStatecode Int = 0,@GSTIN nVarChar(15) = '' 
	,@GSTFullDocID nVarChar(255) = '') 
AS              
DECLARE @DocumentID int              
Declare @GSTDocID Int

SELECT @DocumentID = DocumentID FROM AdjustmentReturnAbstract WHERE adjustmentid=@AdjID 

SELECT @GSTDocID = GSTDocID FROM AdjustmentReturnAbstract WHERE adjustmentid=@AdjID 

     
Insert into AdjustmentReturnAbstract(BillID,AdjustmentDate,VendorID, DocumentID, Value, Balance, Total_Value, DocReference,
	AdjustmentIDRef,DocIDRef, Reference, TaxOnMRP,VATTaxAmount, UserName,GSTFlag,FromStatecode,ToStatecode,GSTIN,GSTDocID,GSTFullDocID)
Values (@BILLID,@ADJUSTMENTDATE,@VENDORID, @DocumentID, @VALUE, @Total_Value,  @Total_Value, @DocReference,
	@AdjId,@DOcIdREf, @Reference, @TaxOnMRP, @VATTaxAmount, @UserName, @GSTFlag, @FromStatecode, @ToStatecode, @GSTIN,@GSTDocID,@GSTFullDocID)

Select @@Identity, @DocumentID              
  
