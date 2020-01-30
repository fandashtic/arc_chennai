Create Procedure UpdateClaimDetail_DandD @ID int
AS
BEGIN
	DECLARE @UOM1 int        
	DECLARE @UOM2 int   
	DECLARE @UOMConv1 Decimal(18,6)        
	DECLARE @UOMConv2 Decimal(18,6) 
	Declare @ClaimId int
	Select @ClaimId= ClaimID from DandDAbstract where ID=@ID
	Delete from claimsdetail where ClaimID=(Select ClaimID from DandDAbstract where ID=@ID)
	Declare @Product_code nvarchar(15)
	Declare ClaimDetail Cursor For Select Distinct Product_code from DandDDetail where ID=@ID 
	Open ClaimDetail
	Fetch from ClaimDetail into @Product_code
	While @@fetch_status=0
	BEGIN
		
		Select @UOM1 = IsNull(Items.UOM1,0),@UOMConv1=Items.UOM1_Conversion, @UOM2 = IsNull(Items.UOM2,0),@UOMConv2=Items.UOM2_Conversion From items where Product_code=@Product_code
		Insert into claimsdetail(ClaimID,Product_Code,quantity,Rate,Batch,PurchasePrice,SchemeType,Batch_code,Serial,UOMID,TaxAmount,TaxSuffPercent,UOMConversion)
		Select @ClaimId,BP.Product_code,D.RFAQuantity,BP.PTS,D.Batch_Number,BP.PTS,0,D.Batch_code,1,D.UOM,D.TaxAmount,BP.TaxSuffered,Case D.UOM when @UOM1 then @UOMConv1 when @UOM2 Then @UOMConv2 else 0 end
		From Batch_Products BP,DandDDetail D
		Where BP.Batch_code=D.Batch_code and D.ID=@ID	
		And D.Product_code=@Product_code and isnull(D.RFAQuantity,0) > 0

		Fetch Next from ClaimDetail into @Product_code
	END
	Close ClaimDetail
	Deallocate ClaimDetail
END
