Create Procedure mERP_Sp_SaveRecCustActiveDeactive
(@ScreenName nvarchar(100),
 @nMenuLock Int,
 @nLockActive Int,
 @nLockRemarks Int
)
As
Begin
	
	Declare @nidentity int   
	Insert into tbl_mERP_RecConfigAbstract(Menuname,flag, Status) values(@ScreenName,@nMenuLock,0)               
	Select @nidentity= @@IDENTITY   


	Insert into tbl_mERP_RecConfigDetail(ID,FieldName,Flag,Status) Values(@nidentity,'Active',@nLockActive,0)
	Insert into tbl_mERP_RecConfigDetail(ID,FieldName,Flag,Status) Values(@nidentity,'Remarks',@nLockRemarks,0)
	
End
