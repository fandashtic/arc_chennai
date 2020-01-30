CREATE Procedure sp_acc_con_rpt_balancesheet(@FromDate DateTime, @ToDate DateTime,@FormatType Int)
As
DECLARE @balance decimal(18,2),@TotalDepAmt decimal(18,2),@GroupCode Int,@group nvarchar(50),@AccountType Int,@stockvalue decimal(18,2)
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

Declare @VERTICALFORMAT Int
Declare @TFORMAT Int
Declare @NORMALFORMAT Int

Set @VERTICALFORMAT = 1
Set @TFORMAT = 2
Set @NORMALFORMAT = 3
If @FormatType=@TFORMAT
Begin
	Exec sp_acc_con_rpt_balancesheetT @FromDate,@ToDate
End
If @FormatType=@VERTICALFORMAT
Begin
	Exec sp_acc_con_rpt_balancesheetVertical @FromDate,@ToDate
End

Else IF @FormatType=@NORMALFORMAT
Begin
	Create table #Temp4(AccountName nvarchar(250),Debit Decimal(18,2) null,Credit Decimal(18,2) null,ToMatch int null,AccountID Int null,FromDate datetime null,ToDate datetime null,DocRef integer null,DocType integer null,HighLight Int null)
	Create table #Temp3(AccountName nvarchar(25),Debit Decimal(18,2) null,Credit Decimal(18,2) null,ToMatch int null,AccountID Int null,FromDate datetime null,ToDate datetime null,DocRef integer null,DocType integer null,ToMatch1 Int null,ToMatch2 Int null,HighLight Int null)	Insert Into #Temp3(AccountName, Debit, Credit, ToMatch, AccountID, FromDate, ToDate, DocRef, DocType, ToMatch1,ToMatch2,Highlight)
	Execute sp_acc_con_rpt_TradingAC @FromDate,@Todate,9 -- Normal format
	
	Insert #Temp4
	Select case when Debit is Null  then N'Loss for the Period' else N'Profit for the Period' end,
	case when debit is null then Credit else Null end,case when Debit is not null then Debit else Null end,
	0,0,@fromdate,@todate,0,0,@SPECIALCASE3 from #Temp3 where AccountName=N'Net Loss' or AccountName=N'Net Profit'
	
	DECLARE scanrootlevel CURSOR KEYSET FOR
	Select GroupID,GroupName,AccountType from ConsolidateAccountGroup where ParentGroup=0 and 
	AccountType in (3,2,1) order by AccountType desc
	
	OPEN scanrootlevel
	
	FETCH FROM scanrootlevel into @GroupCode,@group,@AccountType
	
	WHILE @@FETCH_STATUS =0
	BEGIN
		Set @balance=0
		execute sp_acc_con_rpt_recursivebalance @GroupCode,@fromdate,@todate,@balance output,@TotalDepAmt output
	    	If @AccountType=1
		Begin
			If @TotalDepAmt=0
			Begin
				Insert #Temp4
				Select @Group ,@balance,Null,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
			End
			Else
			Begin
				Insert #Temp4
				Select @Group + N' less depreciation value ' + cast(@TotalDepAmt as nvarchar(50)),@balance,Null,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
			End
	
		End
		Else if @AccountType=2 or @AccountType=3
		Begin
			
			Insert #Temp4
			Select @Group,Null,case when @balance > 0 then (0-@Balance) else abs(@balance) end,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
		End
		FETCH NEXT FROM scanrootlevel into @GroupCode,@group,@AccountType
	END
	CLOSE scanrootlevel
	DEALLOCATE scanrootlevel
	
	Insert #Temp4
	Select 'Total',Sum(Debit),Sum(Credit),0,0,@fromdate,@todate,0,0,@LASTLEVEL from #Temp4
	Select 'Group Name'=AccountName, 'Debit'=Debit,'Credit'=Credit,ToMatch,AccountID,FromDate,ToDate,DocRef,DocType,HighLight,HighLight from #Temp4
	Drop Table #Temp3
	Drop Table #Temp4
	
End

