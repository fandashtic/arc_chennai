CREATE Procedure sp_acc_backdatedaccountopeningbalance(@BackDate datetime,@BackdatedAccountID Int=0)
/* Procedure to update daily opening balance */
As
Declare @CurrentDate Datetime
Declare @LastBalance Decimal(18,6)
Declare @CurrentBalance Decimal(18,6)
Declare @OpeningBalance Decimal(18,6)
Declare @AccountID Int
Declare @TempBackDate datetime
--Get the server date
-- -- set @CurrentDate = dbo.StripDateFromTime(getdate())
set @CurrentDate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))

Set @Backdate = dbo.stripdatefromtime(@BackDate)
Set @TempBackDate=DateAdd(s,0-1,DateAdd(d,1,@BackDate))

IF @Backdate = '30/12/1899' GOTO HELL
--Get the Last updated date from the setup table
--Select @LastUpdated=dbo.stripdatefromtime(OpeningDate) from SetUp

--loop continues until current date matched with lastupdated date
While @Backdate<@CurrentDate
Begin
	If IsNull(@BackdatedAccountID,0)=0
	Begin
		--surf through the AccountMaster table
		DECLARE ScanAccountMaster CURSOR KEYSET FOR
		--Select AccountID from AccountsMaster where isnull(Active,0)=1
		Select AccountID from AccountsMaster where AccountID <> 500

		OPEN ScanAccountMaster
		FETCH FROM ScanAccountMaster INTO @ACCOUNTID
		While @@FETCH_STATUS=0
		Begin
			--get the openingvalue from the AccountOpeningBalance table for each AccountID of lastupdated date
			--Select @LastBalance=isnull(OpeningValue,0) from AccountOpeningBalance where dbo.stripdatefromtime(OpeningDate)=@BackDate and AccountID=@AccountID
			If not exists(Select Top 1 OpeningValue from AccountOpeningBalance where OpeningDate=@BackDate and AccountID=@AccountID) 					
			--Opening Value not available in AccountOpeningbalance table then get the OpeningBalance from the AccountsMaster
			--If isnull(@LastBalance,0)=0
			Begin
				Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId=@AccountID --and isnull(Active,0)=1
			End
			Else
			Begin
				Select @LastBalance=isnull(OpeningValue,0) from AccountOpeningBalance where OpeningDate=@BackDate and AccountID=@AccountID
			End
			--get the current balance from the generalJournal table for each AccountID of the last updated date	
			Select @CurrentBalance= isnull(sum(Debit-Credit),0) from GeneralJournal where
			(TransactionDate between @BackDate and @TempBackDate) and AccountID=@AccountID
			and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
			and isnull(status,0) <> 128 and isnull(status,0) <> 192
			/*if @Accountid=3
			Begin
						Select @Accountid,@CurrentBalance
			End
			*/
			Set @OpeningBalance=isnull(@LastBalance,0)+isnull(@CurrentBalance,0)
			/*if @Accountid=3
			Begin
						Select @AccountID,@OpeningBalance
			End
			*/
			--dont insert if openingbalance of that account is 0
			--If @OpeningBalance<>0
			--Begin
				If not exists(Select Top 1 OpeningValue from AccountOpeningbalance where AccountID=@AccountID and OpeningDate=DateAdd(day,1,@BackDate)) 			
				Begin
					--If @OpeningBalance<>0
					--Begin
						
						Insert AccountOpeningBalance values(@AccountID,DateAdd(day,1,@BackDate),@OpeningBalance)
					--End
				End
				Else
				Begin
					--update the OpeningBalance + Current balance of the last date as Opening Balance
					-- for the next date in AccountOpeningBalance table.
					update AccountOpeningBalance set OpeningValue=@OpeningBalance where AccountID=@AccountID and OpeningDate=DateAdd(day,1,@BackDate)
					/*if @Accountid=3
					begin
						Select @Accountid,@OpeningBalance,dbo.stripdatefromtime(DateAdd(day,1,@BackDate))
					End*/
				End
			--End
			FETCH NEXT FROM ScanAccountMaster INTO @AccountID
			Set @LastBalance=0
			Set @CurrentBalance =0
			Set @OpeningBalance=0
		End
		CLOSE ScanAccountMaster
		DEALLOCATE ScanAccountMaster
	End
	Else
	Begin
			--get the openingvalue from the AccountOpeningBalance table for each AccountID of lastupdated date
			--Select @LastBalance=isnull(OpeningValue,0) from AccountOpeningBalance where dbo.stripdatefromtime(OpeningDate)=@BackDate and AccountID=@AccountID
			If not exists(Select Top 1 OpeningValue from AccountOpeningBalance where OpeningDate=@BackDate and AccountID=@BackdatedAccountID) 					
			--Opening Value not available in AccountOpeningbalance table then get the OpeningBalance from the AccountsMaster
			--If isnull(@LastBalance,0)=0
			Begin
				Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId=@BackdatedAccountID --and isnull(Active,0)=1
			End
			Else
			Begin
				Select @LastBalance=isnull(OpeningValue,0) from AccountOpeningBalance where OpeningDate=@BackDate and AccountID=@BackdatedAccountID
			End
	
			--get the current balance from the generalJournal table for each AccountID of the last updated date	
			Select @CurrentBalance= isnull(sum(Debit-Credit),0) from GeneralJournal where
			(TransactionDate between @BackDate and @TempBackDate) and AccountID=@BackdatedAccountID
			and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82) 
			and isnull(status,0) <> 128 and isnull(status,0) <> 192
			/*if @Accountid=3
			Begin
						Select @Accountid,@CurrentBalance
			End
			*/
			Set @OpeningBalance=isnull(@LastBalance,0)+isnull(@CurrentBalance,0)
			/*if @Accountid=3
			Begin
						Select @AccountID,@OpeningBalance
			End
			*/
			--dont insert if openingbalance of that account is 0
			--If @OpeningBalance<>0
			--Begin
				If not exists(Select Top 1 OpeningValue from AccountOpeningbalance where AccountID=@BackdatedAccountID and OpeningDate=DateAdd(day,1,@BackDate))
				Begin
					--If @OpeningBalance<>0
					--Begin
						
						Insert AccountOpeningBalance values(@BackdatedAccountID,DateAdd(day,1,@BackDate),@OpeningBalance)
					--End
				End
				Else
				Begin
					--update the OpeningBalance + Current balance of the last date as Opening Balance
					-- for the next date in AccountOpeningBalance table.
					update AccountOpeningBalance set OpeningValue=@OpeningBalance where AccountID=@BackdatedAccountID and OpeningDate=DateAdd(day,1,@BackDate)
					/*if @Accountid=3
					begin
						Select @Accountid,@OpeningBalance,dbo.stripdatefromtime(DateAdd(day,1,@BackDate))
					End*/
				End
			--End

			Set @LastBalance=0
			Set @CurrentBalance =0
			Set @OpeningBalance=0
	End
	--Next day of the LastUpdated date
	Set @BackDate=DateAdd(day,1,@BackDate) 
	Set @BackDate = dbo.stripdatefromtime(@BackDate)
	Set @TempBackDate=DateAdd(s,0-1,DateAdd(d,1,@BackDate))
End
HELL:

