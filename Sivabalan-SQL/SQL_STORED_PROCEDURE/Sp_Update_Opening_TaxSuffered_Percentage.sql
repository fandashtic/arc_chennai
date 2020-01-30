CREATE PROCEDURE Sp_Update_Opening_TaxSuffered_Percentage(
@OPENING_DATE Datetime,
@ITEMCODE nvarchar(30),      
@BATCH_CODE Int,
@DEDUCT Int=0,	--Identifies whether the Tax suffered Percentage is to be Added or Deducted.
@UPDATE_CST_TAXSUFFERED Int=0, --Update Cst_TaxSuffered Percentage or not.
@CALLED_FROM_BILL Int=0) 		 --Whether this Proc is called from Bill or not.     
AS
--This Procedure is used to add or deduct taxsuffered percentage in openingdetails 
--from the next date of the given date to current date for the given item 
Declare @Price Decimal(18,6)
Declare @TaxPercentage Decimal(18,6)
Declare @TaxApplicableOn Int
Declare @TaxPartOf Decimal(18,6)
Declare @TaxSufferedAmt Decimal(18,6)
Declare @Qty Decimal(18,6) 
Declare @ServerDate datetime  
Declare @Batch_Value Decimal (18,6)

Set DateFormat dmy
Select @OPENING_DATE = dbo.StripDateFromTime(@OPENING_DATE)
Select @ServerDate = dbo.StripDateFromTime(GetDate())  

IF @OPENING_DATE <= @ServerDate  
BEGIN
	If Exists (Select * From DBO.SysObjects Where Id = Object_ID(N'[Batch_Products_Temp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
	Drop Table [Batch_Products_Temp]  
	Select * into Batch_Products_Temp From Batch_Products Where Batch_Code=@BATCH_CODE

	--Updating Van Stock into Batch_Products
	Update Batch_Products_Temp Set Quantity = Batch_Products_Temp.Quantity + IsNull(VanStatementDetail.Pending,0) 
	From Batch_Products_Temp, VanStatementAbstract, VanStatementDetail 
	WHERE VanStatementDetail.Batch_Code=Batch_Products_Temp.Batch_Code and 
	VanStatementAbstract.DocSerial = VanStatementDetail.DocSerial AND 
	(VanStatementAbstract.Status & 128) = 0 
	
	Select @Qty=IsNull(Quantity,0), @Price=IsNull(PurchasePrice,0), @TaxPercentage=IsNull(TaxSuffered,0), 
			 @TaxApplicableOn=IsNull(ApplicableOn,0), @TaxPartOf=IsNull(PartOfPercentage,0) 
			 From Batch_Products_Temp Where Batch_Code=@BATCH_CODE
	
	Select @TaxSufferedAmt=Dbo.FN_GetTaxSufferedAmt(@ITEMCODE,@Price,@Qty,@TaxPercentage,
																	@TaxApplicableOn,@TaxPartOf,@BATCH_CODE)

	If @CALLED_FROM_BILL = 0 
		Select @Batch_Value = Quantity * IsNull(PurchasePrice,0) from Batch_Products_Temp Where Batch_Code=@BATCH_CODE			
	Else	
		--If this proc is called from bill then we don't need to reduce batch_value in openingdetails 
		--in order to calculate taxsuffered percentage.
		--Because we don't update stock quantity in bill module.
		Select @Batch_Value = 0

	If @DEDUCT = 1	--Deduct Taxsuffered amount and calculate TaxSuffered Per..
		Begin
			Update OpeningDetails 
			Set TaxSuffered_Value=
			(Case When (IsNull(Opening_Value,0)-@Batch_Value) <> 0 Then
			((((IsNull(TaxSuffered_Value,0)/100) * IsNull(Opening_Value,0)) 
		   - @TaxSufferedAmt) / (IsNull(Opening_Value,0)-@Batch_Value)) * 100 
			Else 0 End)
			Where Product_Code=@ITEMCODE And Opening_Date > @OPENING_DATE
	
			If @UPDATE_CST_TAXSUFFERED = 1
				Begin
					--If the given batch is based on CST, Vat then 
					--the CSTTaxsuffered Per.. has to be updated
					Update OpeningDetails 
					Set CST_TaxSuffered=
					(Case When (IsNull(Opening_Value,0)-@Batch_Value) <> 0 Then
					((((IsNull(CST_TaxSuffered,0)/100) * IsNull(Opening_Value,0)) 
				   - @TaxSufferedAmt) / (IsNull(Opening_Value,0)-@Batch_Value)) * 100 
					Else 0 End)
					Where Product_Code=@ITEMCODE And Opening_Date > @OPENING_DATE			
				End
			Else --Batch is not based on CST 
				Begin
					--Whenever the OpeningValue is changed then 
					--the CSTTaxsuffered Per.. should also get changed
					Update OpeningDetails 
					Set CST_TaxSuffered=
					(Case When (IsNull(Opening_Value,0)-@Batch_Value) <> 0 Then
					((((IsNull(CST_TaxSuffered,0)/100) * IsNull(Opening_Value,0))) / 
					(IsNull(Opening_Value,0)-@Batch_Value)) * 100 
					Else 0 End)
					Where Product_Code=@ITEMCODE And Opening_Date > @OPENING_DATE			
				End
		End
	Else	--Add TaxSuffered Amount and calculate TaxSuffered Per..
		Begin
			Update OpeningDetails 
			Set TaxSuffered_Value = 
			(Case When IsNull(Opening_Value,0) <> 0 Then
	      ((((IsNull(TaxSuffered_Value,0)/100) * (IsNull(Opening_Value,0)-@Batch_Value)) 
		   + @TaxSufferedAmt) / Opening_Value) * 100 
			Else 0 End)
			Where Product_Code=@ITEMCODE And Opening_Date > @OPENING_DATE
	
			If @UPDATE_CST_TAXSUFFERED = 1
				Begin
					--If the given batch is based on CST, Vat then 
					--the CSTTaxsuffered Per.. has to be updated
					Update OpeningDetails 
					Set CST_TaxSuffered = 
					(Case When IsNull(Opening_Value,0) <> 0 Then
			      ((((IsNull(CST_TaxSuffered,0)/100) * (IsNull(Opening_Value,0)-@Batch_Value)) 
				   + @TaxSufferedAmt) / Opening_Value) * 100 
					Else 0 End)
					Where Product_Code=@ITEMCODE And Opening_Date > @OPENING_DATE	
				End 
			Else --Batch is not based on CST 
				Begin
					--Whenever the OpeningValue is changed then 
					--the CSTTaxsuffered Per.. should also get changed
					Update OpeningDetails 
					Set CST_TaxSuffered = 
					(Case When IsNull(Opening_Value,0) <> 0 Then
			      ((((IsNull(CST_TaxSuffered,0)/100) * (IsNull(Opening_Value,0)-@Batch_Value))) / 
					Opening_Value) * 100 
					Else 0 End)
					Where Product_Code=@ITEMCODE And Opening_Date > @OPENING_DATE	
				End 
		End

		If Exists (Select * From DBO.SysObjects Where Id = Object_ID(N'[Batch_Products_Temp]') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
		Drop Table [Batch_Products_Temp]  
END


