Create Procedure mERP_SP_MarginPTRUpdated
As
Begin
	
	Select Count(*) From tbl_mERP_ProcessStatus Where isNull(ProcessCode,'') = N'MARGIN' And isNull(Status,0) = 1
End

