Create function dbo.mERP_FN_Get_MRPPerPack(@Product_Code nVarchar(15))
Returns Decimal(18,6)
AS
Begin
	Declare @MRPPerPack Decimal(18,6)
	Declare @Temp Table (Product_Code nvarchar(15), Batch_Code int)
	Insert Into @Temp(Product_Code, Batch_Code)
	Select Product_Code, Max(Batch_Code) From Batch_Products Where Product_Code = @Product_Code
	Group By Product_Code

	IF (Select Count(*) From @Temp) > 0
		Select @MRPPerPack = B.MRPPerPack From Batch_Products B, @Temp T
		Where B.Product_Code=T.Product_Code
		And B.Batch_Code=T.Batch_Code 		
	Else
		Select @MRPPerPack = MRPPerPack From Items Where Product_Code = @Product_Code
	
	Return @MRPPerPack
END
