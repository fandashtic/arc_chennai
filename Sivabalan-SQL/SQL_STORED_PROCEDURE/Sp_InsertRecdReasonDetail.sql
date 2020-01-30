Create Procedure Sp_InsertRecdReasonDetail(@RecdID Int, @Reason nvarchar(255),@Type nvarchar(50),@Active int)
As
Begin
	Set Dateformat DMY
	Insert into RecdReasonDetail(RecdID,Reason,Type,Active,Status)
	Select @RecdID,@Reason,@Type,@Active,0
End
