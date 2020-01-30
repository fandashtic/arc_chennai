CREATE Procedure sp_acc_rpt_balancesheetVertical(@FromDate DateTime,@ToDate DateTime)
As
DECLARE @balance decimal(18,6),@TotalDepAmt decimal(18,6),@GroupCode Int,@group nvarchar(300),@AccountType Int,@stockvalue decimal(18,6)
Declare @NEXTLEVEL INT,@LASTLEVEL INT
Declare @LEAFACCOUNT int
Declare @ACCOUNTGROUP int
Declare @CURRENTASSET int
Declare @SPECIALCASE3 INT

SET @NEXTLEVEL =0 -- Allow Next Level
SET @LASTLEVEL =1 -- No Next Level
SET @LEAFACCOUNT =2 -- link value for account	
SET @ACCOUNTGROUP =3 -- link value for sub groups
SET @CURRENTASSET =17 -- groupid of current asset
SET @SPECIALCASE3=6

Declare @NetDebit Decimal(18,6),@NetCredit Decimal(18,6)

Create table #TempVAsset(AccountName nvarchar(300),Amount Decimal(18,6) null,ToMatch int null,AccountID Int null,FromDate datetime null,ToDate datetime null,DocRef integer null,DocType integer null,HighLight Int null)
Create table #TempVLiability(AccountName nvarchar(300),Amount Decimal(18,6) null,ToMatch int null,AccountID Int null,FromDate datetime null,ToDate datetime null,DocRef integer null,DocType integer null,HighLight Int null)
Create table #TempVertical(AccountName nvarchar(300),Amount Decimal(18,6) null,ToMatch int null,AccountID Int null,FromDate datetime null,ToDate datetime null,DocRef integer null,DocType integer null,HighLight Int null)
Create table #TempVPL(AccountName nvarchar(300),Debit Decimal(18,6) null,Credit Decimal(18,6) null,ToMatch int null,AccountID Int null,FromDate datetime null,ToDate datetime null,DocRef integer null,DocType integer null,ToMatch1 Int null,ToMatch2 Decimal(18,6) null,HighLight Int null)
	
Insert Into #TempVPL(AccountName, Debit, Credit, ToMatch, AccountID, FromDate, ToDate, DocRef, DocType, ToMatch1,ToMatch2,Highlight)
Execute sp_acc_rpt_TradingAC @FromDate,@Todate,3 -- Vertical format

Select @NetDebit= case when Debit is Null  then  0 else Debit  end,
@NetCredit=case when Credit is Null  then  0 else Credit  end 
from #TempVPL where AccountName=N'Net Loss'  or AccountName=N'Net Profit'

If @NetDebit<>0 
Begin
	Insert #TempVLiability
	Select dbo.LookupDictionaryItem('Profit for the Period',Default) ,@NetDebit,0,0,@fromdate,@todate,0,0,@SPECIALCASE3 from #TempVPL where AccountName=N'Net Loss'  or AccountName=N'Net Profit'
End

If @NetCredit<>0 
Begin
	Insert #TempVAsset
	Select dbo.LookupDictionaryItem('Loss for the Period',Default) ,@NetCredit,0,0,@fromdate,@todate,0,0,@SPECIALCASE3 from #TempVPL where AccountName=N'Net Loss'  or AccountName=N'Net Profit'
End

DECLARE scanrootlevel CURSOR KEYSET FOR
Select GroupID,GroupName,AccountType from AccountGroup where ParentGroup=0 and 
AccountType in (3,2,1) order by AccountType desc

OPEN scanrootlevel

FETCH FROM scanrootlevel into @GroupCode,@group,@AccountType

WHILE @@FETCH_STATUS =0
BEGIN
	Set @balance=0
	execute sp_acc_rpt_recursivebalance @GroupCode,@fromdate,@todate,@balance output,@TotalDepAmt output
    	If @AccountType=1
	Begin
/*		IF @groupcode = @CURRENTASSET 
		BEGIN  
			If @Todate<dbo.stripdatefromtime(getdate())
			Begin
				Select @stockvalue=sum(opening_Value)from OpeningDetails 
				where Opening_Date=dateadd(day,1,@ToDate)
			End
			Else
			Begin
				Select @stockvalue= sum(Quantity*PurchasePrice)from Batch_Products


			End
			set @balance = @balance+ isnull(@stockvalue,0)
			Insert #Temp4
 			Select @Group,@Balance,Null,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
		END
		ELSE
		BEGIN  
			Insert #Temp4
 			Select @Group,@Balance,Null,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
		END
*/
		If @TotalDepAmt=0
		Begin
			Insert #TempVAsset
			Select @Group ,@balance,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
		End
		Else
		Begin
			Insert #TempVAsset
			Select @Group + dbo.LookupDictionaryItem(' less depreciation value ',Default) + cast(@TotalDepAmt as nvarchar(50)),@balance,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
		End

	End
	Else if @AccountType=2 or @AccountType=3
	Begin
		
		Insert #TempVLiability
		--Select @Group,Null,abs(@balance),0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
		Select @Group,case when @balance > 0 then (0-@Balance) else abs(@balance) end,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
	End
	FETCH NEXT FROM scanrootlevel into @GroupCode,@group,@AccountType
END
CLOSE scanrootlevel
DEALLOCATE scanrootlevel

Insert #TempVAsset
Select 'Total',Sum(Amount),0,0,@fromdate,@todate,0,0,@LASTLEVEL from #TempVAsset

Insert #TempVLiability
Select 'Total',Sum(Amount),0,0,@fromdate,@todate,0,0,@LASTLEVEL from #TempVLiability

Insert #TempVertical
Select 'Assets',Null,0,0,@fromdate,@todate,0,0,@LASTLEVEL

Insert #TempVertical
Select * from #TempVAsset

Insert #TempVertical
Select Null,Null,0,0,@fromdate,@todate,0,0,@LASTLEVEL

Insert #TempVertical
Select 'Liabilities',Null,0,0,@fromdate,@todate,0,0,@LASTLEVEL

Insert #TempVertical
Select * from #TempVLiability

Select 'Group Name'=AccountName, 'Amount'=Amount,ToMatch,AccountID,FromDate,ToDate,DocRef,DocType,HighLight,HighLight from #TempVertical

Drop Table #TempVPL
Drop Table #TempVAsset
Drop Table #TempVLiability
Drop Table #TempVertical
