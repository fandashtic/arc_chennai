Create Procedure [sp_acc_backdatedaccopeningbal](@BackDate datetime, @BackdatedAccountID int ,@todate datetime)  
/* Procedure to update daily opening balance */  
As  
  
Declare @CurrentDate Datetime  
Declare @LastBalance Decimal(18,6)  
Declare @CurrentBalance Decimal(18,6)  
Declare @OpeningBalance Decimal(18,6)  
Declare @AccountID Int  
Declare @TempBackDate datetime  
Declare @OpeningDate Datetime  
Declare @ActualBalance Decimal(18,6)  
Declare @ActualTrans Decimal(18,6)

SET DATEFORMAT DMY  
Set @Backdate = dbo.StripDateFromTime(@Backdate)
Set @todate =dbo.StripDateFromTime(@todate)
set @CurrentDate =  dbo.StripDateFromTime(getdate()) --dbo.StripDateFromTime(getdate())  
Set @TempBackDate=DateAdd(d,-1,@BackDate) 

Select Top 1 @OpeningDate = OpeningDate From Setup  
Set @openingDate = dbo.stripdatefromtime(@OpeningDate)
if exists (select * from tempdb.dbo.sysobjects where id = object_id(N'#CorrOpeningValue') and OBJECTPROPERTY(id, N'IsUserTable') = 1)  
Begin  
drop table #CorrOpeningValue  
End  
  
Create Table #CorrOpeningValue  
(  
 AccountID Int,  
 OpeningBalance Float  
)  
  
If @BackDate <= @todate  
BEGIN  
   if @Backdate = @OpeningDate
   BEGIN  
    Select @LastBalance= isNull(OpeningBalance,0) from AccountsMaster where AccountId=@BackdatedAccountID  
   END  
   ELSE  
   Begin  
    Select @LastBalance=isnull(OpeningValue,0) from AccountOpeningBalance where OpeningDate=@TempBackDate and AccountID=@BackdatedAccountID  
   End  
   Select @ActualBalance =isnull(OpeningValue,0) from AccountOpeningBalance where OpeningDate=@BackDate and AccountID=@BackdatedAccountID   
     
	Select @ActualTrans= isnull(sum(Debit-Credit),0) from GeneralJournal where  
     (dbo.stripdatefromtime(TransactionDate) = @BackDate) and AccountID=@BackdatedAccountID  
     and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)   
     and isnull(status,0) <> 128 and isnull(status,0) <> 192  

   if @Backdate = @OpeningDate
   BEGIN  
     Set @OpeningBalance=isnull(@LastBalance,0)   
     Delete From AccountOpeningbalance where AccountID=@BackdatedAccountID and OpeningDate=@BackDate  
     Insert AccountOpeningBalance values(@BackdatedAccountID,@BackDate,@OpeningBalance)  
     Insert into #CorrOpeningValue (AccountID, OpeningBalance) Values (@BackdatedAccountID, @OpeningBalance)  
   END  
   ELSE  
   BEGIN  
     Select @CurrentBalance= isnull(sum(Debit-Credit),0) from GeneralJournal where  
     (dbo.stripdatefromtime(TransactionDate) = @TempBackDate) and AccountID=@BackdatedAccountID  
     and documenttype not in (28,29,30,31,32,33,34,35,36,39,60,61,62,63,79,80,81,82)   
     and isnull(status,0) <> 128 and isnull(status,0) <> 192  

     Set @OpeningBalance=isnull(@LastBalance,0)+isnull(@CurrentBalance,0)  
     Delete From AccountOpeningbalance where AccountID=@BackdatedAccountID and OpeningDate=@BackDate  
     Insert AccountOpeningBalance values(@BackdatedAccountID,@BackDate,@OpeningBalance)  
     Insert into #CorrOpeningValue (AccountID, OpeningBalance) Values (@BackdatedAccountID, @OpeningBalance)  
   END  
END  
select [Account Name] = AccountName, [Opening Date]=@BackDate,isnull(@ActualBalance,0)  As [Opening Balance],isnull(@ActualTrans,0) As [Transactions],  
isnull(@ActualBalance,0) + isnull(@ActualTrans,0) As [Current Balance],  
[Corrected Opening Balance] = isnull((Select accountopeningBalance.OpeningValue from accountopeningBalance where Accountid = AccountsMaster.AccountID and OpeningDate=@BackDate),0) from #CorrOpeningValue,AccountsMaster  
Where #CorrOpeningValue.AccountID = AccountsMaster.AccountID  
  
Drop Table #CorrOpeningValue  
