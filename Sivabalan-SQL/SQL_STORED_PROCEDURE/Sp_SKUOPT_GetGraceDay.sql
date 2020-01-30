Create Procedure dbo.Sp_SKUOPT_GetGraceDay
As  
Begin
	Select Top 1 Isnull([Value],0) from tbl_merp_configdetail where screencode='SKUOPT'
End
