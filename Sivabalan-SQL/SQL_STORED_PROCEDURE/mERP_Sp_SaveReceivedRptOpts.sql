Create Procedure mERP_Sp_SaveReceivedRptOpts (@ReportName nvarchar(100),@VisibleOpt int,@UploadOpt int ,@RptTypeOpt int) 
As
Begin

Declare @Recdidentity int

IF (IsNull(@ReportName, '') = N'DFRFLAG')
Begin
	Insert into tbl_mERP_RecConfigAbstract(Menuname,flag, Status) 
	Values (@ReportName,@VisibleOpt, 0)
	Select @RecdIdentity = @@Identity

	Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) 
	values(@RecdIdentity,'UPLOAD',@UploadOpt, 0)  

	Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) 
	values(@RecdIdentity,'DISCORFREE',@RptTypeOpt, 0)
End

IF (IsNull(@ReportName, '') = N'WLVFLAG')
Begin
	Insert into tbl_mERP_RecConfigAbstract(Menuname,flag, Status) 
	Values (@ReportName,@VisibleOpt, 0)
	Select @RecdIdentity = @@Identity

	Insert into  tbl_mERP_RecConfigDetail  (ID,fieldname,flag,Status) 
	values(@RecdIdentity,'UPLOAD',@UploadOpt, 0)  
 		
End

End
