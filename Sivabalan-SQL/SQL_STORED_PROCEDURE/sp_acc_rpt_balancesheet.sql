CREATE Procedure sp_acc_rpt_balancesheet(@FromDate DateTime, @ToDate DateTime,@FormatType Int)
As
DECLARE @balance decimal(18,6),@TotalDepAmt decimal(18,6),@GroupCode Int,@group nvarchar(50),@AccountType Int,@stockvalue decimal(18,6)
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
	Exec sp_acc_rpt_balancesheetT @FromDate,@ToDate
End
If @FormatType=@VERTICALFORMAT
Begin
	Exec sp_acc_rpt_balancesheetVertical @FromDate,@ToDate
End

Else IF @FormatType=@NORMALFORMAT
Begin
	Create table #Temp4(AccountName nvarchar(250),Debit Decimal(18,6) null,Credit Decimal(18,6) null,ToMatch int null,AccountID Int null,FromDate datetime null,ToDate datetime null,DocRef integer null,DocType integer null,HighLight Int null)
	Create table #Temp3(AccountName nvarchar(25),Debit Decimal(18,6) null,Credit Decimal(18,6) null,ToMatch int null,AccountID Int null,FromDate datetime null,ToDate datetime null,DocRef integer null,DocType integer null,ToMatch1 Int null,ToMatch2 Decimal(18,6) null,HighLight Int null)

	Insert Into #Temp3(AccountName, Debit, Credit, ToMatch, AccountID, FromDate, ToDate, DocRef, DocType, ToMatch1,ToMatch2,Highlight)
	Execute sp_acc_rpt_TradingAC @FromDate,@Todate,@FormatType
	
	Insert #Temp4
	Select case when Debit is Null  then dbo.LookupDictionaryItem('Loss for the Period',Default) else dbo.LookupDictionaryItem('Profit for the Period',Default) end,
	case when debit is null then Credit else Null end,case when Debit is not null then Debit else Null end,
	0,0,@fromdate,@todate,0,0,@SPECIALCASE3 from #Temp3 where AccountName=N'Net Loss'  or AccountName=N'Net Profit'
	
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
				Insert #Temp4
				Select @Group ,@balance,Null,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
			End
			Else
			Begin
				Insert #Temp4
				Select @Group + dbo.LookupDictionaryItem(' less depreciation value ',Default) + cast(@TotalDepAmt as nvarchar(50)),@balance,Null,0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
			End
	
		End
		Else if @AccountType=2 or @AccountType=3
		Begin
			
			Insert #Temp4
			--Select @Group,Null,abs(@balance),0,@GroupCode,@fromdate,@todate,0,0,@ACCOUNTGROUP
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
