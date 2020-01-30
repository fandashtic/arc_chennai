Create Procedure mERP_sp_UpdateSetupGGDRFlag
As
Begin

If Exists(Select Top 1 'X' From PendingGGRRFinalDataPost)
Begin
	Update SetUp set GGRRDaycloseFlag = 1
End

End
