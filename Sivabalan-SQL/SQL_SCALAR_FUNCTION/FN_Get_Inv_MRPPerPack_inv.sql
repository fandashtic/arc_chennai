Create function dbo.FN_Get_Inv_MRPPerPack_inv(@Product_Code nVarchar(15), @Batch_Code int)
Returns Decimal(18,6)
AS
Begin
	Declare @MRPPerPack Decimal(18,6)
	If @Batch_Code=0
	Begin
			Select @MRPPerPack = IsNull(I.MRPPerPack, 0)
			From Items I
			Where I.Product_Code = @Product_Code
	End
	Else
	Begin
		
		if exists(select 'x' from Batch_Products BP, Items I,VanStatementDetail VD
		Where I.Product_Code = BP.Product_Code and 
		BP.Product_code=VD.Product_code And
		VD.Product_code=@Product_Code And
		I.Product_Code = @Product_Code and VD.ID = @Batch_Code
		And BP.Batch_Code=VD.Batch_Code)
		Begin
			Select @MRPPerPack = IsNull(BP.MRPPerPack, 0)
			From Batch_Products BP, Items I,VanStatementDetail VD
			Where I.Product_Code = BP.Product_Code and 
			BP.Product_code=VD.Product_code And
			VD.Product_code=@Product_Code And
			I.Product_Code = @Product_Code and VD.ID = @Batch_Code
			And BP.Batch_Code=VD.Batch_Code
		End
		Else
		--	If exists (select 'x' from batch_products where product_code=@Product_Code and batch_code=@Batch_Code)
		Begin
			Select @MRPPerPack = IsNull(BP.MRPPerPack, 0)
			From Batch_Products BP, Items I
			Where I.Product_Code = BP.Product_Code and 
			I.Product_Code = @Product_Code and BP.Batch_Code = @Batch_Code
		End
End
	Return @MRPPerPack
END
