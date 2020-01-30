Create Procedure mERP_sp_UpdateMarginFlag
As
Begin
	If ((Select Count(*) From tbl_mERP_Margin_Log) > 0 ) 
		Update tbl_mERP_ProcessStatus Set Status = 1 Where ProcessCode = 'MARGIN'
End
