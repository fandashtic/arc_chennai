Create Procedure Sp_InsertRecdGGDROutlet(
	@RecdID Nvarchar(255),
	@FromDate Nvarchar(10),
	@ToDate Nvarchar(10),
	@OutletID Nvarchar(15),
	@OutletStatus Nvarchar(20),
	@Target Nvarchar(255),
	@TargetUOM Nvarchar(10),
	@CatGroup Nvarchar(10),
	@OCG Nvarchar(10),
	@PMCatGroup Nvarchar(7),
	@ProdDefnID Int,
	@Active Int,
	@Flag nvarchar(100))
As  
Begin  
	SET DATEFORMAT DMY
	Insert Into Recd_GGDROutlet (RecDocID,FromDate,ToDate,OutletID,OutletStatus,Target,TargetUOM,CatGroup,OCG,PMCatGroup,ProdDefnID,Active,Status,CreationDate,Flag)
	Select @RecdID,@FromDate,@ToDate,@OutletID,@OutletStatus,cast(@Target as Decimal(18,6)),cast(@TargetUOM as Int),@CatGroup,@OCG,@PMCatGroup,@ProdDefnID,@Active,0,Getdate(),@Flag
End  
