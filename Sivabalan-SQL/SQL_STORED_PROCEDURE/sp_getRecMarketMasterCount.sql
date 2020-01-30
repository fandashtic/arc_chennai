Create Procedure sp_getRecMarketMasterCount 
As  
Begin
	Select Distinct Count(RecFlag) From RecdMarketInfoAbstract  Where isnull(RecFlag,0) = 0  
End
