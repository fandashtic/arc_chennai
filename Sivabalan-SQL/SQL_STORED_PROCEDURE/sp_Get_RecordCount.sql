Create Procedure sp_Get_RecordCount
As
Begin
	Select count(*) From mLang..MlangResources
End
