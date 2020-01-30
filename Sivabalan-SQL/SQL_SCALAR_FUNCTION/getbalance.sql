CREATE Function getbalance(@documentid integer,@documenttype integer)
Returns Decimal(18,6)
AS

Begin
declare @balance Decimal(18,6)
if @documenttype =4
begin
select @balance =isnull(Balance,0)from
APVAbstract where [DocumentID] = @documentid
and isnull(Status,0)<> 192
end
else if @documenttype =5
begin
select @balance =isnull(Balance,0)from
DebitNote where [DebitID] = @documentid
and (isnull(Status,0) & 64) = 0
end
else if @documenttype =2
begin
select @balance =isnull(Balance,0)from
CreditNote where [CreditID] = @documentid
and (isnull(Status,0) & 64) = 0
end
else if @documenttype = 6
begin
select @balance =isnull(Balance,0)from
ARVAbstract where [DocumentID] = @documentid
and (isnull(Status,0) & 64) = 0
end
else if @documenttype = 7
begin
select @balance =isnull(Balance,0)from
Collections where [DocumentID] = @documentid
and (isnull(Status,0) & 64) = 0
end
else if @documenttype = 8 or @documenttype = 9
begin
select @balance =isnull(Balance,0)from
ManualJournal where [NewRefID] = @documentid
and isnull(Status,0) <> 128 and isnull(Status,0) <> 192
end
else if @documenttype = 3
begin
select @balance =isnull(Balance,0)from
Payments where [DocumentID] = @documentid
and isnull(Status,0) <> 128 and isnull(Status,0) <> 192
End
Else IF @documenttype = 151  Or @documenttype = 153
Begin
Select @balance = isnull(Balance,0) From
ServiceAbstract Where InvoiceID = @documentid
and isnull(Status,0) <> 4
End
Else IF @documenttype = 155
Begin
Select @balance = Balance From DandDInvAbstract where DandDInvID = @documentid
End

Return IsNULL(@balance,0)
End

