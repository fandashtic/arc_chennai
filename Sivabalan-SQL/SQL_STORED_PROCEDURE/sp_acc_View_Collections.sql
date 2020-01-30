


CREATE procedure sp_acc_View_Collections(@Mode Int,@AccountID nvarchar(15),
				  @FromDate datetime,
				  @ToDate datetime)
as
Declare @VIEW Int,@CANCEL Int
Set @VIEW=2
Set @CANCEL=1

If @AccountID=0
Begin

	If @Mode=@VIEW
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,FullDocID,Collections.Documentdate,
		Collections.Value,PaymentMode,Status,Collections.DocumentID
		from Collections,AccountsMaster where Collections.CustomerID is Null and 
		--Collections.DocumentID in (Select CollectionID from CollectionDetail where CollectionDetail.Others=@AccountID group by CollectionDetail.CollectionID)
		Collections.Others is not Null and Collections.DocumentDate between @FromDate and @ToDate and
		AccountsMaster.AccountID=Collections.Others
		order by AccountsMaster.AccountName, Collections.DocumentDate
	End
	Else IF @Mode=@CANCEL 
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,FullDocID,Collections.Documentdate,
		Collections.Value,PaymentMode,Status,Collections.DocumentID
		from Collections,AccountsMaster where Collections.CustomerID is Null and 
		Collections.Others is not null and Collections.DocumentDate between @FromDate and @ToDate 
		and AccountsMaster.AccountID=Collections.Others and
		(IsNull(Collections.Status, 0) & 192) = 0 And IsNull(Collections.Status, 0) = 0
		order by AccountsMaster.AccountName, Collections.DocumentDate
	End

End
Else 
Begin
	If @Mode=@VIEW
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,FullDocID,Collections.Documentdate,
		Collections.Value,PaymentMode,Status,Collections.DocumentID
		from Collections,AccountsMaster where Collections.CustomerID is Null and 
		--Collections.DocumentID in (Select CollectionID from CollectionDetail where CollectionDetail.Others=@AccountID group by CollectionDetail.CollectionID)
		Collections.Others=@AccountID and Collections.DocumentDate between @FromDate and @ToDate 
		and AccountsMaster.AccountID=Collections.Others and
		(IsNull(Collections.Status, 0) & 192) = 0 And IsNull(Collections.Status, 0) = 0
		order by AccountsMaster.AccountName, Collections.DocumentDate
	End	
	Else If @Mode=@CANCEL
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,FullDocID,Collections.Documentdate,
		Collections.Value,PaymentMode,Status,Collections.DocumentID
		from Collections,AccountsMaster where Collections.CustomerID is Null and 
		--Collections.DocumentID in (Select CollectionID from CollectionDetail where CollectionDetail.Others=@AccountID group by CollectionDetail.CollectionID)
		Collections.Others is not Null and Collections.Others=@AccountID
		and Collections.DocumentDate between @FromDate and @ToDate 
		and AccountsMaster.AccountID=Collections.Others
		order by AccountsMaster.AccountName, Collections.DocumentDate
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











