Create function dbo.FN_Get_Inv_MRPPerPack(@Product_Code nVarchar(15), @Batch_Code int)
Returns Decimal(18,6)
AS
Begin
	Declare @MRPPerPack Decimal(18,6)
	
	Select @MRPPerPack = Case When IsNull(BP.MRPPerPack, 0) = 0 Then IsNull(I.MRPPerPack, 0) Else IsNull(BP.MRPPerPack, 0) End
	From Batch_Products BP, Items I
	Where I.Product_Code = BP.Product_Code and 
		I.Product_Code = @Product_Code and BP.Batch_Code = @Batch_Code
	
	Return @MRPPerPack
END
