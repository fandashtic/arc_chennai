Create Procedure mERP_Sp_get_RecdLPAchievementCount
As
Begin
	Select Count(*) From LP_RecdDocAbstract Where DocType =N'LPACHIEVEMENT' and Status = 0
End
