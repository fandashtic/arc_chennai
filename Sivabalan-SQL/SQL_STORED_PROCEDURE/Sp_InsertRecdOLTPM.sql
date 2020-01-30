Create Procedure Sp_InsertRecdOLTPM(@RecdDocID Int,@PMCode Nvarchar(255),@DStypeID Int,@ParameterID Int,@OutletID Nvarchar(255),@Target Decimal(18,6),@OCG Nvarchar(255),@CG Nvarchar(255))
As
Begin
	Set DateFormat DMY
	Insert Into Recd_PMOLT (RecdDocID,PMCode,DStypeID,ParameterID,OutletID,Target,OCG,CG,Status,CreationDate)
	Select @RecdDocID,@PMCode,@DStypeID,@ParameterID,@OutletID,@Target,@OCG,@CG,0,Getdate()
	Select @@Identity
End
