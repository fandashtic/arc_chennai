CREATE procedure sp_acc_loadcashaccount(@accountid integer,@mode integer)
As
DECLARE @openingvalue decimal(18,6),@currentdate datetime,@tempcurrentdate datetime
DECLARE @balance decimal(18,6)
DECLARE @account integer
DECLARE @exist integer
DECLARE @Additions decimal(18,6)
DECLARE @Sales decimal(18,6)
DECLARE @OpeningBalance decimal(18,6)
DECLARE @TranID integer
DECLARE @Debit decimal(18,6)
DECLARE @Credit decimal(18,6)
DECLARE @ClosingBalanceBeforeDepriciation decimal(18,6)
DECLARE @DepPercent decimal(18,6)
DECLARE @DepAmount decimal(18,6)

DECLARE @LEDGERBALANCE integer
DECLARE @CHEQUE Integer
DECLARE @DD integer

SET @LEDGERBALANCE =0
SET @CHEQUE =1
SET @DD =2

set dateformat dmy
-- -- set @currentdate =dbo.stripdatefromtime(getdate())
set @currentdate = dbo.stripdatefromtime(dbo.Sp_Acc_GetOperatingDate(getdate()))
Set @tempcurrentdate =DateAdd(s,0-1,(DateAdd(dd,1,@currentdate)))
/*
DECLARE @FIXEDASSET integer
DECLARE @DEPRECIATION integer
SET @FIXEDASSET =13
SET @DEPRECIATION=24

exec sp_acc_fixedaccountexists @FIXEDASSET,@accountid, @exist output
if @exist = 1
begin
Set @Additions=0
Set @Sales=0
Select @OpeningBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountID =@accountid
Declare scanGJDep Cursor Keyset for
Select TransactionID,Debit,Credit from GeneralJournal where AccountID=@accountid
and isnull(status,0) <> 128 and isnull(status,0) <> 192
Open ScanGJDep
Fetch from scangjdep into @TranID,@Debit,@Credit
While @@Fetch_Status=0
Begin
If not exists(Select AccountID from GeneralJournal where TransactionID=@TranID and AccountID=@DEPRECIATION)
Begin
Set @Additions=isnull(@Additions,0)+isnull(@Debit,0)
Set @Sales=isnull(@Sales,0) + isnull(@Credit,0)
End
Fetch Next from scangjdep into @TranID,@Debit,@Credit
End
Close scangjdep
Deallocate scangjdep
--select @Additions=sum(isnull(debit,0)),@Sales=sum(isnull(Credit,0)) from generaljournal where AccountID = @AccountID
Set @ClosingBalanceBeforeDepriciation=(@OpeningBalance+@Additions)-@Sales
Set @DepPercent=isnull((Select AdditionalField1 from AccountsMaster where AccountID=@AccountID),0)
If @DepPercent>0
Begin
Set @DepAmount=@ClosingBalanceBeforeDepriciation * (@DepPercent/100)
If @DepAmount > 0
Begin
Set @ClosingBalanceAfterDepriciation=@ClosingBalanceBeforeDepriciation-@DepAmount
End
End

end
*/

If @mode =@LEDGERBALANCE -- For all accounts closing balance
Begin

if not exists (select top 1 OpeningValue from accountopeningbalance where [AccountID]=@accountid and OpeningDate =@currentdate)
begin
Select @openingvalue = isNull(OpeningBalance,0) from AccountsMaster
where AccountID=@accountID -- and isnull([Active],0)=1
end
else
begin
select @openingvalue = isnull(OpeningValue,0) from accountopeningbalance
where [AccountID]=@accountid and OpeningDate =@currentdate
end

 select @balance = sum(isnull(debit,0) - isnull(credit,0)) from GeneralJournal,AccountsMaster
 where ([TransactionDate] between @currentdate and @tempcurrentdate) and
 [GeneralJournal].AccountID = @accountid and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
 and isnull(status,0) <> 128 and isnull(status,0) <> 192
 and [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID]

select isnull(@openingvalue,0) + isnull(@balance,0)
End
Else if @mode = @CHEQUE or @mode = @DD
Begin

select @account = AccountID from Bank where [BankID]= @accountid
if not exists (select top 1 OpeningValue from accountopeningbalance where [AccountID]=@account and OpeningDate =@currentdate)
begin
Select @openingvalue = isNull(OpeningBalance,0) from AccountsMaster
where AccountID=@account -- and isnull([Active],0)=1

end
else
begin
select @openingvalue = isnull(OpeningValue,0) from accountopeningbalance
where [AccountID]=@account and OpeningDate =@currentdate

end

 select @balance = sum(isnull(debit,0) - isnull(credit,0)) from GeneralJournal,AccountsMaster
 where ([TransactionDate] between @currentdate and @tempcurrentdate)
 and [GeneralJournal].AccountID = @account and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)
 and isnull(status,0) <> 128 and isnull(status,0) <> 192
 and [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID]

select isnull(@openingvalue,0) + isnull(@balance,0)
End

