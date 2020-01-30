Create Procedure sp_CloseRecMarketMasterCount 
As  
Begin
	Update 	RecdMarketInfoAbstract set RecFlag = 32 Where isnull(RecFlag,0) = 0 
End
