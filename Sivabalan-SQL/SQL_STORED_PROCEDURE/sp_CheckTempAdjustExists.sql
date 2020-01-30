Create Procedure sp_CheckTempAdjustExists 
As
Begin
	If Not Exists(Select * From tempdb..sysobjects Where name = '##TempAdjust')
		Create Table ##TempAdjust(sno int)
End
