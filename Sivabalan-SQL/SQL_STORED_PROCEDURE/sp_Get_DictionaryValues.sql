Create Procedure sp_Get_DictionaryValues(@Type nVarchar(255))
As
Begin
	Select DefaultValue,LocalizedValue From mLang..mLangResources Where Type = @Type
End

