Create Function [dbo].[Fn_Get_DandDPrice](@GRNID int, @ItemCode nvarchar(20), @Serial int, @PTS Decimal(18,6))
Returns Decimal(18,6)
As
Begin
	Declare @DandDPrice Decimal(18,6)
	Declare @BillID int

	Select Top 1 @BillID = BillID From GRNAbstract Where GRNID = @GRNID

	Select Top 1 @DandDPrice = isnull(PFM,0) From BillDetail BD Where BD.BillID = @BillID and BD.Product_Code = @ItemCode and BD.Serial = @Serial

	IF isnull(@DandDPrice,0) = 0
		Set @DandDPrice = @PTS

	Return @DandDPrice
End 
