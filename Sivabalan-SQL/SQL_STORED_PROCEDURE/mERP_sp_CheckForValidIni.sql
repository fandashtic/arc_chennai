Create Procedure mERP_sp_CheckForValidIni(@IniName nVarchar(500),@PrintMode Int)
As
Begin
	If Exists(Select * From tbl_mERP_RestrictedIniFiles Where IniFileName = @IniName And PrintMode = @PrintMode And Active = 1)
		Select 0
	Else
		Select 1
End
