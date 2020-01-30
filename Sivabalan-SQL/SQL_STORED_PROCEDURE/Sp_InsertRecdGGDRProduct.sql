Create Procedure Sp_InsertRecdGGDRProduct(
	@RecdID Int,
	@ProdDefnID Int,
	@Products Nvarchar(256),
	@IsExcluded Int,
	@ProdCatLevel Int,
	@ProductFlag Nvarchar(10),
	@Target Nvarchar(10),
	@TargetUOM Int,
	@Points Decimal(18,6))
As  
Begin  
	SET DATEFORMAT DMY
	Insert Into Recd_GGDRProduct (RecDocID,ProdDefnID,Products,IsExcluded,ProdCatLevel,ProductFlag,Target,TargetUOM,Status,CreationDate,Points)
	Select @RecdID,@ProdDefnID,@Products,@IsExcluded,@ProdCatLevel,@ProductFlag,cast(@Target as Decimal(18,6)),@TargetUOM,0,Getdate(),@Points
End  
