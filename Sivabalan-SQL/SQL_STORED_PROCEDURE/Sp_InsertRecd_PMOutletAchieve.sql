Create Procedure Sp_InsertRecd_PMOutletAchieve(@RecdDocID Int,@PMCode Nvarchar(255),@DStypeID Int,@ParameterID Int,@OutletID Nvarchar(255),@Target int,@OCG Nvarchar(255),@CG Nvarchar(255),@ParamType nvarchar(30))
As
Begin
	Set DateFormat DMY
	Insert Into Recd_PMOutletAchieve (RecdDocID,PMCode,DStypeID,ParameterID,OutletID,Target,OCG,CG,Status,CreationDate,ParamType)
	Select @RecdDocID,@PMCode,@DStypeID,@ParameterID,@OutletID,@Target,@OCG,@CG,0,Getdate(),@ParamType
	Select @@Identity
End
