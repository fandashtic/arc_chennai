Create Procedure mERP_sp_GetLatestIni(@Transaction nVarchar(255),@PrintMode Int = 0)
As
Begin
	If @PrintMode = 0 
		Select IniName,isNull(PrintMode,0) From tbl_mERP_TransactionIni
		Where TransactionName = @Transaction And Active = 1
	Else
		Select IniName,isNull(PrintMode,0) From tbl_mERP_TransactionIni
		Where TransactionName = @Transaction And Active = 1 And PrintMode = @PrintMode 

End
