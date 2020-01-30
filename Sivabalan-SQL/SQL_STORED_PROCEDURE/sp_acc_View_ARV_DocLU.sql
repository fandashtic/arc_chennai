CREATE procedure sp_acc_View_ARV_DocLU (@Mode Int,@FromDocID int,
					   @ToDocID int,@DocumentRef nvarchar(510)=N'')
as
Declare @VIEW Int,@CANCEL Int,@AMEND Int
Set @AMEND = 1
Set @CANCEL = 2
Set @VIEW = 3

If Len(ltrim(rtrim(@DocumentRef))) = 0 
Begin
	If @Mode=@VIEW
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,
		dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID as nvarchar(15)),
		ARVDate,Amount,Status,DocumentID,DocRef,Balance,RefDocID 
		from ARVAbstract,AccountsMaster 
		where 
		(dbo.GetTrueVal(ARVID) between @FromDocID and @ToDocID
		OR 
		(Case Isnumeric(DocRef) 
			When 1 then Cast(DocRef as int)
		end) 
		BETWEEN @FromDocID AND @ToDocID)
		and AccountsMaster.AccountID=PartyAccountID
		order by AccountsMaster.AccountName,AccountsMaster.AccountID,ARVDate
	End
	Else IF @Mode=@CANCEL 
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,
		dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID as nvarchar(15)),
		ARVDate,Amount,Status,DocumentID,DocRef,Balance,RefDocID 
		from ARVAbstract,AccountsMaster 
		where 
		(dbo.GetTrueVal(ARVID) between @FromDocID and @ToDocID
		OR 
		(Case Isnumeric(DocRef) 
			When 1 then Cast(DocRef as int)
		end) 
		BETWEEN @FromDocID AND @ToDocID)
		and	AccountsMaster.AccountID=PartyAccountID and
		(IsNull(Status, 0) & 192) = 0 And (IsNull(Status,0) & 128) = 0 And IsNull(Status, 0) = 0
		order by AccountsMaster.AccountName,AccountsMaster.AccountID, ARVDate
	End
	Else IF @Mode=@AMEND 
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,
		dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID as nvarchar(15)),
		ARVDate,Amount,Status,DocumentID,DocRef,Balance,RefDocID 
		from ARVAbstract,AccountsMaster 
		where (dbo.GetTrueVal(ARVID) between @FromDocID and @ToDocID
		OR 
		(Case Isnumeric(DocRef) 
			When 1 then Cast(DocRef as int)
		end) 
		BETWEEN @FromDocID AND @ToDocID)
		and AccountsMaster.AccountID=PartyAccountID
		order by AccountsMaster.AccountName,AccountsMaster.AccountID,ARVDate
	End
End
Else 
Begin
	If @Mode=@CANCEL
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,
		dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID as nvarchar(15)),ARVDate,
		Amount,Status,DocumentID,DocRef,Balance,RefDocID 
		from ARVAbstract,AccountsMaster 
		where 
		(
		(DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'
		and (
		Case ISnumeric(Substring(DocRef,Len(@DocumentRef)+1,Len(DocRef))) 
		When 1 then Cast(Substring(DocRef,Len(@DocumentRef)+1,Len(DocRef))as int)End) 
		BETWEEN @FromDocID AND @ToDocID)
		or 
		(DocRef = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
		)
		and AccountsMaster.AccountID=PartyAccountID and
		(IsNull(Status, 0) & 192) = 0 And (IsNull(Status,0) & 128) = 0 And IsNull(Status, 0) = 0
		order by AccountsMaster.AccountName,AccountsMaster.AccountID,ARVDate
	End	
	Else If @Mode=@VIEW
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,
		dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID as nvarchar(15)),
		ARVDate,Amount,Status,DocumentID,DocRef,Balance,RefDocID 
		from ARVAbstract,AccountsMaster 
		where 		
		(
		(DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'
		and (
		Case ISnumeric(Substring(DocRef,Len(@DocumentRef)+1,Len(DocRef))) 
		When 1 then Cast(Substring(DocRef,Len(@DocumentRef)+1,Len(DocRef))as int)End) 
		BETWEEN @FromDocID AND @ToDocID)
		or 
		(DocRef = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
		)
		and AccountsMaster.AccountID=PartyAccountID
		order by AccountsMaster.AccountName,AccountsMaster.AccountID, ARVDate
	End
	Else IF @Mode=@AMEND 
	Begin
		Select AccountsMaster.AccountName,AccountsMaster.AccountID,
		dbo.getvoucherprefix('ACCOUNTS RECEIVABLE VOUCHER') + Cast(ARVID as nvarchar(15)),
		ARVDate,Amount,Status,DocumentID,DocRef,Balance,RefDocID 
		from ARVAbstract,AccountsMaster 
		where 
		(
		(DocRef LIKE  @DocumentRef + N'%' + N'[0-9]'
		and (
		Case ISnumeric(Substring(DocRef,Len(@DocumentRef)+1,Len(DocRef))) 
		When 1 then Cast(Substring(DocRef,Len(@DocumentRef)+1,Len(DocRef))as int)End) 
		BETWEEN @FromDocID AND @ToDocID)
		or 
		(DocRef = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
		)
		and AccountsMaster.AccountID=PartyAccountID 
		order by AccountsMaster.AccountName,AccountsMaster.AccountID,ARVDate
	End
End


