CREATE Procedure sp_acc_loadpaymentabstract(@accountid int,@fromdate datetime,@todate datetime,    
@type int,@mode int)    
as    
Declare @PAYMENT_TO_PARTY int    
Declare @PAYMENT_TO_EXPENSE int    
Declare @PAYMENT_TO_PARTY_EXPENSE int    
Declare @CANCEL int    
Declare @VIEW int    
Declare @PETTY_CASH int    
Declare @AMEND INT    
    
set @PAYMENT_TO_PARTY =0    
set @PAYMENT_TO_PARTY_EXPENSE =1    
set @PAYMENT_TO_EXPENSE =2    
    
Set @AMEND = 2    
set @CANCEL = 3    
set @VIEW = 4    
    
set @PETTY_CASH =4    
    
if @mode = @CANCEL    
begin    
  if @type = @PAYMENT_TO_PARTY     
  begin    
   if @accountid =0    
   begin    
    select 'Party'= dbo.getaccountname(isnull(Others,0)),FullDocID,    
    DocumentDate,Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)),    
    'Status'=isnull(Status,0),'PartyID'= isnull(Others,0),DocumentID,    
    'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef from Payments     
    where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate     
    and isnull(ExpenseAccount,0)=0 and isnull(Others,0)<> 0    
    and Payments.Others <> @PETTY_CASH     
    and (isnull(Status,0) & 64)= 0 And (isNull(Status,0) & 128) = 0 order by Payments.Others    
   end    
   else    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,    
    DocumentDate,Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)),    
    'Status'=isnull(Status,0),'PartyID'= isnull(Others,0),DocumentID,    
    'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef from Payments    
    where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate    
    and isnull(Others,0)= @accountid and isnull(ExpenseAccount,0)=0    
    and Payments.Others <> @PETTY_CASH and (isnull(Status,0) & 64)= 0 And (isNull(Status,0) & 128) = 0     
    order by Payments.Others    
   end    
  end    
  else if @type = @PAYMENT_TO_EXPENSE    
  begin    
   if @accountid =0    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)),    
    Status,'PartyID'= isnull(Others,0), DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
    from Payments where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate     
    and isnull(Others,0)=0 and isnull(ExpenseAccount,0)<> 0 and (isnull(Status,0) & 64)= 0 And (isNull(Status,0) & 128) = 0   
    order by Payments.ExpenseAccount    
   end    
   else    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)),Status,    
    'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef from Payments    
    where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate    
    and isnull(ExpenseAccount,0)= @accountid and isnull(Others,0)=0      
    and isnull(ExpenseAccount,0)<> 0 and (isnull(Status,0) & 64)= 0 And (isNull(Status,0) & 128) = 0   
    order by Payments.ExpenseAccount     
   end     
  end       
  else if @type = @PAYMENT_TO_PARTY_EXPENSE    
  begin    
   if @accountid =0    
   begin    
    select 'Party'= dbo.getaccountname(isnull(Others,0)),FullDocID,    
    DocumentDate,Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)),    
    'Status'=isnull(Status,0),'PartyID'= isnull(Others,0),DocumentID,    
    'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef from Payments     
    where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate     
    and isnull(ExpenseAccount,0)<> 0 and isnull(Others,0)<> 0     
    and Payments.Others <> @PETTY_CASH     
    and (isnull(Status,0) & 64)= 0 And (isNull(Status,0) & 128) = 0 order by Payments.Others    
   end    
   else    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,    
    DocumentDate,Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)),    
    'Status'=isnull(Status,0),'PartyID'= isnull(Others,0),DocumentID,    
    'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef from Payments    
    where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate    
    and isnull(Others,0)= @accountid and isnull(ExpenseAccount,0)<>0    
    and Payments.Others <> @PETTY_CASH    
    and (isnull(Status,0) & 64)= 0 And (isNull(Status,0) & 128) = 0 order by Payments.Others    
   end    
  end    
end    
else if @mode =@VIEW    
begin    
  if @type = @PAYMENT_TO_PARTY      
  begin    
   if @accountid =0    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
    Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
    from Payments where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate     
    and isnull(ExpenseAccount,0)=0 and isnull(Others,0)<> 0    
    and Payments.Others <> @PETTY_CASH    
    order by Payments.Others    
   end    
   else    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense' = dbo.getaccountname(isnull(ExpenseAccount,0)),Status,    
    'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef from Payments    
    where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate    
    and isnull(Others,0)= @accountid and isnull(ExpenseAccount,0)=0    
    and Payments.Others <> @PETTY_CASH    
    order by Payments.Others    
   end    
  end    
  else if @type = @PAYMENT_TO_EXPENSE    
  begin    
   if @accountid =0    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense'=dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
    Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
    from Payments where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate     
    and isnull(Others,0)=0 and isnull(ExpenseAccount,0)<> 0    
    order by Payments.ExpenseAccount    
   end    
   else    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense' = dbo.getaccountname(isnull(ExpenseAccount,0)),Status,    
    'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef from Payments    
    where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate    
    and isnull(ExpenseAccount,0)= @accountid and    
    isnull(Others,0)=0 and isnull(ExpenseAccount,0)<> 0     
    order by Payments.ExpenseAccount    
   end    
  end       
  else if @type =@PAYMENT_TO_PARTY_EXPENSE     
  begin    
   if @accountid =0    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
    Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
    from Payments where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate     
    and isnull(ExpenseAccount,0)<>0 and isnull(Others,0)<> 0    
    and Payments.Others <> @PETTY_CASH    
    order by Payments.Others    
   end    
   else    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense' = dbo.getaccountname(isnull(ExpenseAccount,0)),Status,    
    'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef from Payments    
    where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate    
    and isnull(Others,0)= @accountid and isnull(ExpenseAccount,0)<>0    
    and Payments.Others <> @PETTY_CASH    
    order by Payments.Others    
   end    
  end    
end    
Else If @mode = @AMEND    
begin    
  if @type = @PAYMENT_TO_PARTY      
  begin    
   if @accountid =0    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
    Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
    from Payments where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate     
    and isnull(ExpenseAccount,0)=0 and isnull(Others,0)<> 0    
    and Payments.Others <> @PETTY_CASH    
    order by Payments.Others    
   end    
   else    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense' = dbo.getaccountname(isnull(ExpenseAccount,0)),Status,    
    'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef from Payments    
    where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate    
    and isnull(Others,0)= @accountid and isnull(ExpenseAccount,0)=0    
    and Payments.Others <> @PETTY_CASH    
    order by Payments.Others    
   end    
  end    
  else if @type = @PAYMENT_TO_EXPENSE    
  begin    
   if @accountid =0    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense'=dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
    Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
    from Payments where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate     
    and isnull(Others,0)=0 and isnull(ExpenseAccount,0)<> 0    
    order by Payments.ExpenseAccount    
   end    
   else    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense' = dbo.getaccountname(isnull(ExpenseAccount,0)),Status,    
    'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef from Payments    
    where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate    
    and isnull(ExpenseAccount,0)= @accountid and    
    isnull(Others,0)=0 and isnull(ExpenseAccount,0)<> 0     
    order by Payments.ExpenseAccount    
   end    
  end       
  else if @type =@PAYMENT_TO_PARTY_EXPENSE     
  begin    
   if @accountid =0    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense'= dbo.getaccountname(isnull(ExpenseAccount,0)) ,    
    Status,'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef    
    from Payments where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate     
    and isnull(ExpenseAccount,0)<>0 and isnull(Others,0)<> 0    
    and Payments.Others <> @PETTY_CASH    
    order by Payments.Others    
   end    
   else    
   begin    
    select 'Party' = dbo.getaccountname(isnull(Others,0)),FullDocID,DocumentDate,    
    Value,Balance,'Expense' = dbo.getaccountname(isnull(ExpenseAccount,0)),Status,    
    'PartyID'= Others, DocumentID,'ExpenseID'=isnull(ExpenseAccount,0),'RefDocID' = IsNull(RefDocID,0),'DocRef' = Payments.DocRef from Payments    
    where dbo.stripdatefromtime(DocumentDate) between @fromdate and @todate    
    and isnull(Others,0)= @accountid and isnull(ExpenseAccount,0)<>0    
    and Payments.Others <> @PETTY_CASH    
    order by Payments.Others    
   end    
  end    
end 
