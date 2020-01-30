CREATE Procedure sp_acc_loadapv(@fromdate datetime,@todate datetime,
@partyid integer,@mode integer,@option integer)
as
DECLARE @ALL INTEGER
DECLARE @SPECIFIC INTEGER
DECLARE @CANCEL INTEGER
DECLARE @AMENDMENT INTEGER
DECLARE @VIEW INTEGER
DECLARE @prefix nvarchar(10)

SET @ALL =0
SET @SPECIFIC =2
SET @AMENDMENT = 1
SET @CANCEL = 2
SET @VIEW = 3

select @prefix =Prefix from VoucherPrefix
where [TranID]=N'ACCOUNTS PAYABLE VOUCHER'

Set @fromdate = dbo.stripdatefromtime(@fromdate)
Set @todate = dbo.stripdatefromtime(@todate)
Set @todate = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))          

if @option = @CANCEL
begin
	if @mode = @ALL 
	begin
		select DocumentID,APVID,'APV ID'= @prefix + cast(APVID as nvarchar(10)),APVDate,'AccountName'=AccountName,
		AmountApproved,PartyAccountID,RefDocID,'DocRef' = APVAbstract.DocumentReference from APVAbstract,AccountsMaster 
		where (APVDate Between @fromdate And @todate)And 
      (IsNull(Status, 0) & 192) = 0 And (IsNull(Status,0) & 128) = 0 And
		[APVAbstract].[PartyAccountID]=[AccountsMaster].[AccountID]
		order by AccountName,DocumentID
	end
	else 
	begin
		select DocumentID,APVID,'APV ID'= @prefix + cast(APVID as nvarchar(10)),APVDate,'AccountName'=AccountName,
		AmountApproved,PartyAccountID,RefDocID,'DocRef' = APVAbstract.DocumentReference from APVAbstract,AccountsMaster where [PartyAccountID]=@partyid and
      (APVDate Between @fromdate And @todate)And 
      (IsNull(Status, 0) & 192) = 0 And (IsNull(Status,0) & 128) = 0 And
		[APVAbstract].[PartyAccountID]=[AccountsMaster].[AccountID]
		order by DocumentID
	end
end
else if @option = @VIEW Or @Option = @AMENDMENT
begin
	if @mode = @ALL 
	begin
		select DocumentID,APVID,'APV ID'= @prefix + cast(APVID as nvarchar(10)),APVDate,'AccountName'=AccountName,
		AmountApproved,'Status'=isnull(Status,0),PartyAccountID,RefDocID,'DocRef' = APVAbstract.DocumentReference from APVAbstract,AccountsMaster
		where (APVDate Between @fromdate And @todate)And 
      [APVAbstract].[PartyAccountID]=[AccountsMaster].[AccountID]
		order by AccountName,DocumentID		
  	end
	else 
	begin
		select DocumentID,APVID,'APV ID'= @prefix + cast(APVID as nvarchar(10)),APVDate,'AccountName'=AccountName,
		AmountApproved,'Status'=isnull(Status,0),PartyAccountID,RefDocID,'DocRef' = APVAbstract.DocumentReference from APVAbstract,AccountsMaster 
		where [PartyAccountID]=@partyid And (APVDate Between @fromdate And @todate)And 
      [APVAbstract].[PartyAccountID]=[AccountsMaster].[AccountID]
		order by DocumentID
	end
end
