CREATE Procedure sp_acc_masterAccountOpening(@AccountID Int)
/* Procedure to update daily opening balance */
As
Declare @CurrentDate Datetime
Declare @LastDate Datetime
Declare @BackDate Datetime
Declare @LastBalance Decimal(18,6)
Declare @CurrentBalance Decimal(18,6)
Declare @OpeningBalance Decimal(18,6)
Declare @TempBackDate DateTime
Set DateFormat DMY
--Get the server date
-- -- set @CurrentDate = dbo.StripDateFromTime(getdate())
set @CurrentDate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))
select @BackDate=OpeningDate from setup
Set @Backdate = dbo.stripdatefromtime(@BackDate)
IF @Backdate = '30/12/1899' GOTO HELL

Select @LastDate=Min(OpeningDate) from AccountOpeningBalance where AccountID=@AccountID
-- Bug Corrected: Account OpeningBalance is not updated when Opening balance is given in Modify Account
if @LastDate is null 
BEGIN
	Select Top 1 @LastDate= openingDate from Setup
END
Set @LastDate = dbo.stripdatefromtime(@LastDate)

If @LastDate>= @BackDate
Begin
	Set @BackDate=DateAdd(day,-1,@LastDate)
	Set @TempBackDate=DateAdd(s,0-1,DateAdd(dd,1,@BackDate))
	--loop continues until current date matched with lastupdated date
	While @Backdate<@CurrentDate
	Begin
		--surf through the AccountMaster table
			--get the openingvalue from the AccountOpeningBalance table for each AccountID of lastupdated date
			If not exists(Select Top 1 OpeningValue from AccountOpeningBalance where OpeningDate=@BackDate and AccountID=@AccountID)
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
			and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63) 
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
		--Next day of the LastUpdated date
		Set @BackDate=DateAdd(day,1,@BackDate) 
		Set @BackDate = dbo.stripdatefromtime(@BackDate)
		Set @TempBackDate=DateAdd(s,0-1,DateAdd(dd,1,@BackDate))
	End
End
HELL:

