CREATE Procedure Sp_get_TypeFromMlangResources
As
Begin
	Select Distinct Type From mLang..mLangResources
End
