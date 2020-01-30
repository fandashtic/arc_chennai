Create Procedure mERP_Sp_get_RecdLPScoreCount
As
Begin
	Select Count(*) From LP_RecdDocAbstract Where DocType =N'LPSCORE' and Status = 0
End
