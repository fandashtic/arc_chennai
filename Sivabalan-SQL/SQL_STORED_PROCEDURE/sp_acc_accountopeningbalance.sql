CREATE Procedure sp_acc_accountopeningbalance
/* Procedure to update daily opening balance */
As
Declare @LastUpdated Datetime
Declare @CurrentDate Datetime
Declare @LastBalance Decimal(18,6)
Declare @CurrentBalance Decimal(18,6)
Declare @OpeningBalance Decimal(18,6)
Declare @AccountID Int

Declare @TempLastUpdated DateTime
--Get the server date
set @CurrentDate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))
--Get the Last updated date from the setup table
--Select @LastUpdated=dbo.stripdatefromtime(OpeningDate) from SetUp
Select @LastUpdated=max(OpeningDate) from AccountOpeningBalance

If @LastUpdated is null Select @LastUpdated=dbo.stripdatefromtime(OpeningDate) from SetUp
Set @TempLastUpdated = DateAdd(s,0-1,DateAdd(dd,1,@LastUpdated))
--loop continues until current date matched with lastupdated date]
If @LastUpdated>@CurrentDate
Begin
	Delete AccountOpeningBalance Where OpeningDate > @CurrentDate
End
While @LastUpdated<@CurrentDate
Begin
	--surf through the AccountMaster table
	DECLARE ScanAccountMaster CURSOR KEYSET FOR
	Select AccountID from AccountsMaster where AccountID <> 500

	OPEN ScanAccountMaster
	FETCH FROM ScanAccountMaster INTO @ACCOUNTID
	While @@FETCH_STATUS=0
	Begin
		--get the openingvalue from the AccountOpeningBalance table for each AccountID of lastupdated date
		Set @LastBalance=0
		If Not exists(Select top 1 openingvalue from AccountOpeningBalance where OpeningDate=@LastUpdated and AccountID=@AccountID)
		Begin
			Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId=@AccountID --and isnull(Active,0)=1
		End
			
		set @LastBalance= isnull(@LastBalance,0) + isnull((Select OpeningValue from AccountOpeningBalance where OpeningDate=@LastUpdated and AccountID=@AccountID),0)
		--get the current balance from the generalJournal table for each AccountID of the last updated date	
		Select @CurrentBalance= isnull(sum(Debit-Credit),0) from GeneralJournal where TransactionDate between @LastUpdated and @TempLastUpdated
		and AccountID=@AccountID and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
		and isnull(status,0) <> 128 and isnull(status,0) <> 192
		--Insert the OpeningBalance + Current balance of the last date as Opening Balance
		-- for the next date in AccountOpeningBalance table.
		Set @OpeningBalance=isnull(@LastBalance,0)+isnull(@CurrentBalance,0)
		--dont insert if openingbalance of that account is 0
		--If @OpeningBalance<>0
		--Begin
			Insert into AccountOpeningBalance (AccountID,OpeningDate,OpeningValue) Values (@AccountID,DateAdd(day,1,@LastUpdated),@OpeningBalance)
		--End
		FETCH NEXT FROM ScanAccountMaster INTO @AccountID
	End
	CLOSE ScanAccountMaster
	DEALLOCATE ScanAccountMaster

	--Next day of the LastUpdated date
	Select @LastUpdated=DateAdd(day,1,@LastUpdated) 
	Set @TempLastUpdated = DateAdd(s,0-1,DateAdd(dd,1,@LastUpdated))
End

