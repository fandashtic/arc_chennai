CREATE procedure sp_acc_View_ARV(@Mode Int,@AccountID nvarchar(15),
				  @FromDate datetime,
				  @ToDate datetime)
as
Declare @VIEW Int,@CANCEL Int,@AMEND Int
Set @AMEND = 1
Set @CANCEL = 2
Set @VIEW = 3

If @AccountID=0
Begin
	If @Mode=@VIEW
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID as nvarchar(15)),ARVDate,
		Amount,Status,DocumentID,DocRef,Balance,RefDocID from ARVAbstract,AccountsMaster where ARVDate between 
		@FromDate and @ToDate and AccountsMaster.AccountID=PartyAccountID
		order by AccountsMaster.AccountName,AccountsMaster.AccountID, ARVDate
	End
	Else IF @Mode=@CANCEL 
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID as nvarchar(15)),ARVDate,
		Amount,Status,DocumentID,DocRef,Balance,RefDocID from ARVAbstract,AccountsMaster where ARVDate between
		@FromDate and @ToDate and AccountsMaster.AccountID=PartyAccountID and
		(IsNull(Status, 0) & 192) = 0 And (IsNull(Status,0) & 128) = 0 And IsNull(Status, 0) = 0
		order by AccountsMaster.AccountName,AccountsMaster.AccountID, ARVDate
	End
	Else IF @Mode=@AMEND 
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID as nvarchar(15)),ARVDate,
		Amount,Status,DocumentID,DocRef,Balance,RefDocID from ARVAbstract,AccountsMaster where ARVDate between 
		@FromDate and @ToDate and AccountsMaster.AccountID=PartyAccountID
		order by AccountsMaster.AccountName,AccountsMaster.AccountID,ARVDate
	End
End
Else 
Begin
	If @Mode=@CANCEL
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID as nvarchar(15)),ARVDate,
		Amount,Status,DocumentID,DocRef,Balance,RefDocID from ARVAbstract,AccountsMaster where 		
		PartyAccountID=@AccountID and ARVDate between @FromDate and @ToDate 
		and AccountsMaster.AccountID=PartyAccountID and
		(IsNull(Status, 0) & 192) = 0 And (IsNull(Status,0) & 128) = 0 And IsNull(Status, 0) = 0
		order by AccountsMaster.AccountName,AccountsMaster.AccountID, ARVDate
	End	
	Else If @Mode=@VIEW
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID as nvarchar(15)),ARVDate,
		Amount,Status,DocumentID,DocRef,Balance,RefDocID from ARVAbstract,AccountsMaster where 		
		PartyAccountID=@AccountID and ARVDate between @FromDate and @ToDate 
		and AccountsMaster.AccountID=PartyAccountID
		order by AccountsMaster.AccountName,AccountsMaster.AccountID, ARVDate
	End
	Else IF @Mode=@AMEND 
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID as nvarchar(15)),ARVDate,
		Amount,Status,DocumentID,DocRef,Balance,RefDocID from ARVAbstract,AccountsMaster where ARVDate between 
		@FromDate and @ToDate and AccountsMaster.AccountID=PartyAccountID And PartyAccountID=@AccountID
		order by AccountsMaster.AccountName,AccountsMaster.AccountID,ARVDate
	End
End
/*
Declare @CASH Int,@CHEQUEINHAND Int,@ALL Int
Set @CASH=3
Set @CHEQUEINHAND=7
Set @ALL=0
Create table #Temp(AccountName varchar(250),AccountID Integer,CollectionID varchar(50),DocumentDate datetime,
		Value decimal(18,6),PaymentMode integer,Status integer,DocumentID integer)
If @AccountID=@CASH or @AccountID=@CHEQUEINHAND
Begin
	Insert #Temp
	select AccountsMaster.AccountName, Accountsmaster.AccountID, Collections.FullDocID, Collections.DocumentDate, 
	Value,PaymentMode,Status, Collections.DocumentID
	from Collections, Accountsmaster
	where Collections.CustomerID is null and
	Collections.DocumentDate between @FromDate and @ToDate 
	and AccountsMaster.AccountID=@AccountID
	order by AccountsMaster.AccountName, Collections.DocumentDate
End
Else if @AccountID=0
Begin

	Insert #Temp
	select AccountsMaster.AccountName, Accountsmaster.AccountID, Collections.FullDocID, Collections.DocumentDate, 
	Value,PaymentMode,Status, Collections.DocumentID
	from Collections, Accountsmaster
	where Collections.CustomerID is null and
	Collections.DocumentDate between @FromDate and @ToDate 
	and AccountsMaster.AccountID in (case when Paymentmode=0 then @CASH Else @CHEQUEINHAND END)
	order by AccountsMaster.AccountName, Collections.DocumentDate

	Insert #Temp
	Select AccountsMaster.AccountName,AccountsMaster.AccountID,FullDocID,Collections.Documentdate,
	CollectionDetail.AdjustedAmount,PaymentMode,Status,Collections.DocumentID
	from Collections,CollectionDetail,AccountsMaster where Collections.CustomerID is Null and 
	--Collections.DocumentID in (Select CollectionID from CollectionDetail where CollectionDetail.Others=@AccountID group by CollectionDetail.CollectionID)
	Collections.DocumentID=CollectionDetail.CollectionID and CollectionDetail.Others is not null
	and Collections.DocumentDate between @FromDate and @ToDate 
	and AccountsMaster.AccountID=CollectionDetail.Others
	order by AccountsMaster.AccountName, Collections.DocumentDate

--Select 'All Accounts'
End
Else 
Begin
	Insert #Temp
	Select AccountsMaster.AccountName,AccountsMaster.AccountID,FullDocID,Collections.Documentdate,
	CollectionDetail.AdjustedAmount,PaymentMode,Status,Collections.DocumentID
	from Collections,CollectionDetail,AccountsMaster where Collections.CustomerID is Null and 
	--Collections.DocumentID in (Select CollectionID from CollectionDetail where CollectionDetail.Others=@AccountID group by CollectionDetail.CollectionID)
	Collections.DocumentID=CollectionDetail.CollectionID and CollectionDetail.Others=@AccountID
	and Collections.DocumentDate between @FromDate and @ToDate 
	and AccountsMaster.AccountID=CollectionDetail.Others
	order by AccountsMaster.AccountName, Collections.DocumentDate
	
End
Select * from #temp order by AccountName,DocumentDate
Drop Table #Temp
*/
