CREATE Procedure sp_acc_loadapv_DocLU(@Mode Int,@FromDocID int,
			   @ToDocID int,@DocumentRef nvarchar(510)=N'')
as
DECLARE @CANCEL INTEGER
DECLARE @AMENDMENT INTEGER
DECLARE @VIEW INTEGER
DECLARE @prefix nvarchar(10)

SET @AMENDMENT = 2
SET @CANCEL = 3
SET @VIEW = 4

select @prefix =Prefix from VoucherPrefix
where [TranID]=N'ACCOUNTS PAYABLE VOUCHER'

If Len(ltrim(rtrim(@DocumentRef))) = 0 
Begin
	if @Mode = @CANCEL
	begin
		select DocumentID,APVID,'APV ID'= @prefix + cast(APVID as nvarchar(10)),APVDate,
		'AccountName'=AccountName,AmountApproved,PartyAccountID,RefDocID,
		'DocRef' = APVAbstract.DocumentReference 
		from 	
		APVAbstract,AccountsMaster 
		where 
		(dbo.GetTrueVal(APVID) between @FromDocID and @ToDocID
		OR 
		(Case Isnumeric(DocumentReference) 
			When 1 then Cast(DocumentReference as int)
		end) 
		BETWEEN @FromDocID AND @ToDocID)
	  	and (IsNull(Status, 0) & 192) = 0 And (IsNull(Status,0) & 128) = 0 And
		[APVAbstract].[PartyAccountID]=[AccountsMaster].[AccountID]
		order by AccountName,DocumentID
	end
	else if @Mode = @VIEW Or @Mode = @AMENDMENT
	begin
		select DocumentID,APVID,'APV ID'= @prefix + cast(APVID as nvarchar(10)),APVDate,
		'AccountName'=AccountName,AmountApproved,'Status'=isnull(Status,0),PartyAccountID,
		RefDocID,'DocRef' = APVAbstract.DocumentReference 
		from 	
		APVAbstract,AccountsMaster
		where 
		(dbo.GetTrueVal(APVID) between @FromDocID and @ToDocID
		OR 
		(Case Isnumeric(DocumentReference) 
			When 1 then Cast(DocumentReference as int)
		end) 
		BETWEEN @FromDocID AND @ToDocID)
	  	and [APVAbstract].[PartyAccountID]=[AccountsMaster].[AccountID]
		order by AccountName,DocumentID		
	end
End
Else
Begin
	if @Mode = @CANCEL
	begin
		select DocumentID,APVID,'APV ID'= @prefix + cast(APVID as nvarchar(10)),APVDate,'AccountName'=AccountName,
		AmountApproved,PartyAccountID,RefDocID,'DocRef' = APVAbstract.DocumentReference from APVAbstract,AccountsMaster 
		where 
		(
		(DocumentReference LIKE  @DocumentRef + N'%' + N'[0-9]'
		and (
		Case ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))) 
		When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End) 
		BETWEEN @FromDocID AND @ToDocID)
		or 
		(DocumentReference = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
		)
		and	(IsNull(Status, 0) & 192) = 0 And (IsNull(Status,0) & 128) = 0 And
		[APVAbstract].[PartyAccountID]=[AccountsMaster].[AccountID]
		order by AccountName,DocumentID
	end
	else if @Mode = @VIEW Or @Mode = @AMENDMENT
	begin
		select DocumentID,APVID,'APV ID'= @prefix + cast(APVID as nvarchar(10)),APVDate,
		'AccountName'=AccountName,AmountApproved,'Status'=isnull(Status,0),
		PartyAccountID,RefDocID,'DocRef' = APVAbstract.DocumentReference 
		from 
		APVAbstract,AccountsMaster
		where 
		(
		(DocumentReference LIKE  @DocumentRef + N'%' + N'[0-9]'
		and (
		Case ISnumeric(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))) 
		When 1 then Cast(Substring(DocumentReference,Len(@DocumentRef)+1,Len(DocumentReference))as int)End) 
		BETWEEN @FromDocID AND @ToDocID)
		or 
		(DocumentReference = @DocumentRef and @FromDocID = 0 and @ToDocID = 0)
		)
		And 
	  	[APVAbstract].[PartyAccountID]=[AccountsMaster].[AccountID]
		order by AccountName,DocumentID		
	end
End


