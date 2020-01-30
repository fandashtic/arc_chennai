CREATE Procedure [dbo].[sp_acc_rpt_BalanceSheetT](@FromDate DateTime,@ToDate dateTime)
As
DECLARE @balance decimal(18,6),@TotalDepAmt decimal(18,6),@GroupCode Int,@group nvarchar(250),@AccountType Int,@stockvalue decimal(18,6)
Declare @NEXTLEVEL INT,@LASTLEVEL INT
Declare @LEAFACCOUNT int
Declare @ACCOUNTGROUP int
Declare @CURRENTASSET int
Declare @SPECIALCASE3 INT
Declare @NetDebit Decimal(18,6),@NetCredit Decimal(18,6)
Declare @AssetCount Int,@LiabilityCount Int
SET @NEXTLEVEL =0 -- Allow Next Level
SET @LASTLEVEL =1 -- No Next Level
SET @LEAFACCOUNT =2 -- link value for account	
SET @ACCOUNTGROUP =3 -- link value for sub groups
SET @CURRENTASSET =17 -- groupid of current asset
SET @SPECIALCASE3=6

Create Table #TempBalanceSheetT(Liability nvarchar(250),LAmount Decimal(18,6),LAccountID Int,
Assets nVarchar(250),AAmount Decimal(18,6),AAccountID Int,ToMatch int null,FromDate datetime null,ToDate datetime null,DocRef integer null,DocType integer null,HighLight Int null)

Create Table #TempAsset(AccountName nvarchar(250),Value Decimal(18,6) null,ToMatch int null,AccountID Int null,FromDate datetime null,ToDate datetime null,DocRef integer null,DocType integer null,SNo Int IDENTITY(1,1) ,HighLight Int null)
Create Table #TempLiability(AccountName nvarchar(250),Value Decimal(18,6) null,ToMatch int null,AccountID Int null,FromDate datetime null,ToDate datetime null,DocRef integer null,DocType integer null,SNo Int IDENTITY(1,1) ,HighLight Int null)
Create Table #TempPL(AccountName nvarchar(25),Debit Decimal(18,6) null,Credit Decimal(18,6) null,
ToMatch int null,AccountID Int null,FromDate datetime null,ToDate datetime null,DocRef integer null,DocType integer null,ToMatch1 Int null,ToMatch2 Decimal(18,6) null,HighLight Int null)

Insert Into #TempPL(AccountName, Debit, Credit, ToMatch, AccountID, FromDate, ToDate, DocRef, DocType, ToMatch1,ToMatch2,Highlight)
Execute sp_acc_rpt_TradingAC @FromDate,@Todate,3 -- Normal shape

Select @NetDebit= case when Debit is Null  then  0 else Debit  end,
@NetCredit=case when Credit is Null  then  0 else Credit  end 
from #TempPL where AccountName=N'Net Loss' or AccountName=N'Net Profit'

If @NetDebit<>0 
Begin
	Insert #TempLiability
	Select dbo.LookupDictionaryItem('Profit for the Period',Default) ,@NetDebit,0,0,@fromdate,@todate,0,0,@SPECIALCASE3 from #TempPL where AccountName=N'Net Loss'  or AccountName=N'Net Profit' 
End

If @NetCredit<>0 
Begin
	Insert #TempAsset
	Select dbo.LookupDictionaryItem('Loss for the Period',Default) ,@NetCredit,0,0,@fromdate,@todate,0,0,@SPECIALCASE3 from #TempPL where AccountName=N'Net Loss'  or AccountName=N'Net Profit' 
End

DECLARE scanrootlevel CURSOR KEYSET FOR
Select GroupID,GroupName,AccountType from AccountGroup where ParentGroup=0 and 
AccountType in (1,2,3) order by AccountType desc

OPEN scanrootlevel

FETCH FROM scanrootlevel into @GroupCode,@group,@AccountType

WHILE @@FETCH_STATUS =0
BEGIN
	Set @balance=0
	execute sp_acc_rpt_recursivebalance @GroupCode,@fromdate,@todate,@balance output,@TotalDepAmt output
    	If @AccountType=1
	Begin
		If @TotalDepAmt=0
		Begin
			Insert #TempAsset
			Select @Group ,@balance,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
		End
		Else
		Begin
			Insert #TempAsset
			Select @Group + dbo.LookupDictionaryItem(' less depreciation value ',Default) + cast(@TotalDepAmt as nvarchar(50)),@balance,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
		End

	End
	Else if @AccountType=2 or @AccountType=3
	Begin
		
		Insert #TempLiability
		Select @Group,Case when @balance > 0 then (0-@Balance) else abs(@balance) end,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
	End
	FETCH NEXT FROM scanrootlevel into @GroupCode,@group,@AccountType
END
CLOSE scanrootlevel
DEALLOCATE scanrootlevel

Select @AssetCount=Count(*) from #TempAsset
Select @LiabilityCount=Count(*) from #TempLiability
If @AssetCount=@LiabilityCount
Begin
	Insert #TempBalanceSheetT
	Select 'Liability'=#TempLiability.AccountName,'Amount'=#TempLiability.Value,'AccountID'=#TempLiability.AccountID,
	'Asset'=#TempAsset.AccountName,'Amount'=#TempAsset.Value,'AccountID'=#TempAsset.AccountID,
	#TempAsset.ToMatch,#TempAsset.FromDate,#TempAsset.Todate,#TempAsset.DocRef,#TempAsset.DocType,
	--Case When @NetDebit <>0 then  #TempLiability.HighLight Else #TempAsset.HighLight End
	Case When #TempLiability.AccountName = dbo.LookupDictionaryItem('Profit for the Period',Default)  Then #TempLiability.HighLight Else #TempAsset.HighLight End
	from #TempAsset,#TempLiability where #TempAsset.SNo=#TempLiability.SNo
End
Else If @AssetCount>@LiabilityCount
begin
	Insert #TempBalanceSheetT
	Select 'Liability'=#TempLiability.AccountName,'Amount'=#TempLiability.Value,'AccountID'=#TempLiability.AccountID,
	'Asset'=#TempAsset.AccountName,'Amount'=#TempAsset.Value,'AccountID'=#TempAsset.AccountID,
	#TempAsset.ToMatch,#TempAsset.FromDate,#TempAsset.Todate,#TempAsset.DocRef,#TempAsset.DocType,
	--Case When @NetDebit <>0 then  #TempLiability.HighLight Else #TempAsset.HighLight End
	Case When #TempLiability.AccountName = dbo.LookupDictionaryItem('Profit for the Period',Default)  Then #TempLiability.HighLight Else #TempAsset.HighLight End
	from #TempAsset
	Left Join #TempLiability on #TempAsset.SNo = #TempLiability.SNo
	--#TempAsset,#TempLiability
	--where #TempAsset.SNo *= #TempLiability.SNo
End
Else If @AssetCount<@LiabilityCount
Begin
	Insert #TempBalanceSheetT
	Select 'Liability'=#TempLiability.AccountName,'Amount'=#TempLiability.Value,'AccountID'=#TempLiability.AccountID,
	'Asset'=#TempAsset.AccountName,'Amount'=#TempAsset.Value,'AccountID'=#TempAsset.AccountID,
	#TempLiability.ToMatch,#TempLiability.FromDate,#TempLiability.Todate,#TempLiability.DocRef,#TempLiability.DocType,
	--Case When @NetCredit <>0 then  #TempAsset.HighLight Else #TempLiability.HighLight End
	Case When #TempAsset.AccountName = dbo.LookupDictionaryItem('Loss for the Period',Default)  Then #TempAsset.HighLight Else #TempLiability.HighLight End
	from #TempAsset
	Right Join #TempLiability on #TempAsset.SNo = #TempLiability.SNo
	
	--where #TempAsset.SNo =* #TempLiability.SNo
End
Insert #TempBalanceSheetT
Select 'Total',Sum(LAmount),0,'',Sum(AAmount),0,0,@FromDate,@Todate,0,0,@LASTLEVEL from #TempBalanceSheetT

Select Liability ,'Amount'=LAmount ,LAccountID,Assets ,'Amount'=AAmount ,AAccountID ,HighLight ,
FromDate ,ToDate ,DocRef ,DocType ,HighLight from #TempBalanceSheetT

Drop Table #TempPL
Drop Table #TempAsset
Drop Table #TempLiability
Drop Table #TempBalanceSheetT
