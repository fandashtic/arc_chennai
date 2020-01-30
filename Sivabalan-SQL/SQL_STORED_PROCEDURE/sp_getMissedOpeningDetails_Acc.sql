CREATE procedure sp_getMissedOpeningDetails_Acc (@OPENING_DATE datetime)
as  
	--Missed Accounts  
--	If exists(Select TOP 1 AccountID from AccountOpeningBalance)
--		Select AccountName From accountsmaster  
--		where AccountID not in 
--		(Select AccountID From AccountOpeningBalance 
--		Where openingDate = @OPENING_DATE union all select 500) --500 = User Account Start
--		And accountID in (Select AccountID from AccountOpeningBalance Where openingDate = DateAdd(dd,-1,@OPENING_DATE))
--	Else
		Select Top 1 AccountName From accountsmaster Where 1 = 0
