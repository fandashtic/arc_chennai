CREATE Procedure Sp_Upgrade_Saleorder_Serial
AS
---For WA Alone
Declare @SONumber int
Declare @OldSONumber int
Declare  @ItemCode nvarchar(15)
Declare @BatchNumber nvarchar(255)
Declare @SalePrice Decimal(18,6)
Declare @RequiredQuantity Decimal(18,6)
Declare @PendingQuantity Decimal(18,6)
Declare @SaleTax Decimal(18,6)
Declare @Discount Decimal(18,6)
Declare @TAXCODE2 float
Declare @TAXSUFFERED Decimal(18,6) 
Declare @VAT int
Declare @TaxApplicableOn int
Declare @TaxPartOff decimal(18,6)
Declare @TaxSuffApplicableOn int
Declare @TaxSuffPartOff decimal(18,6)
Declare @SerialNo int


Select @OldSONumber=0
Select @SerialNo=0

Declare SaleOrderAutoSerial Cursor For
	Select 	SONumber,Product_Code,Batch_Number,Quantity,Pending,SalePrice,SaleTax,Discount,TaxCode2,TaxSuffered,VAT,TaxApplicableOn,TaxPartOff,TaxSuffApplicableOn,TaxSuffPartOff
From Sodetail Where 
Serial IS NULL

Open SaleOrderAutoSerial
Fetch Next From SaleOrderAutoSerial into 
		@SONumber, 
		@ItemCode, 
		@BatchNumber,  
		@RequiredQuantity,
		@PendingQuantity, 
		@SalePrice, 
		@SaleTax, 
		@Discount,
		@TAXCODE2,
		@TAXSUFFERED,
		@VAT,
		@TaxApplicableOn,
		@TaxPartOff,
		@TaxSuffApplicableOn,
		@TaxSuffPartOff
While @@Fetch_Status =0
Begin
	If (@OldSONumber <> @SONumber)  	Select @SerialNo=1


	Select @OldSONumber=@SONumber			

	Update Sodetail Set Serial=@SerialNo Where 
	SONumber =@SONumber And  
	Product_Code =@ItemCode And  	
	Batch_Number =@BatchNumber And   	
	Quantity =@RequiredQuantity And 	
	Pending =@PendingQuantity And  	
	SalePrice =@SalePrice And  	
	SaleTax =@SaleTax And  	
	Discount =@Discount And 	
	TaxCode2 =@TAXCODE2 And 	
	TaxSuffered =@TAXSUFFERED And 	
	VAT =@VAT And 	
	TaxApplicableOn =@TaxApplicableOn And 	
	TaxPartOff =@TaxPartOff And 	
	TaxSuffApplicableOn =@TaxSuffApplicableOn And 	
	TaxSuffPartOff=@TaxSuffPartOff	

Select	@SONumber, 	@ItemCode, 	@BatchNumber,  		@RequiredQuantity,
		@PendingQuantity, 
		@SalePrice, 
		@SaleTax, 
		@Discount,
		@TAXCODE2,
		@TAXSUFFERED,
		@VAT,
		@TaxApplicableOn,
		@TaxPartOff,
		@TaxSuffApplicableOn,
		@TaxSuffPartOff

Select @SerialNo=@SerialNo +1 

	Fetch Next From SaleOrderAutoSerial into 
		@SONumber, 
		@ItemCode, 
		@BatchNumber,  
		@RequiredQuantity,
		@PendingQuantity, 
		@SalePrice, 
		@SaleTax, 
		@Discount,
		@TAXCODE2,
		@TAXSUFFERED,
		@VAT,
		@TaxApplicableOn,
		@TaxPartOff,
		@TaxSuffApplicableOn,
		@TaxSuffPartOff
End

Close SaleOrderAutoSerial
Deallocate SaleOrderAutoSerial

Update Sodetail Set TaxApplicableOn=1,TaxPartoff=100 Where (ISNULL(SaleTax, 0) + ISNULL(TaxCode2, 0)) >0 And Isnull(TaxApplicableOn,0)=0 And Isnull(TaxPartoff,0)=0
 
Update Sodetail Set TaxSuffApplicableOn=1,TaxSuffPartOff=100 Where (ISNULL(Taxsuffered, 0)) >0 And Isnull(TaxSuffApplicableOn,0)=0 And Isnull(TaxSuffPartOff,0)=0


