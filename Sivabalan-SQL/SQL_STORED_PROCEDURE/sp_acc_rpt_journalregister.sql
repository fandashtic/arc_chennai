CREATE procedure [dbo].[sp_acc_rpt_journalregister](@fromdate datetime,@todate datetime,@accountid integer,@State Int=0)        
as         
DECLARE @account nvarchar(30),@prefix nvarchar(10)         
select @prefix =[Prefix] from [voucherPrefix] where [TranID]=N'Manual Journal'              
set dateformat dmy        
      
Declare @ToDatePair datetime      
Set @ToDatePair = DateAdd(s, 0-1, DateAdd(dd, 1, @todate))        
If @State=0    
 Begin     
  If @accountid = 0        
  Begin        
   select 'TransactionID'= @prefix + cast(DocumentNumber as nvarchar),        
   'Transaction Date'= dbo.stripdatefromtime(TransactionDate),        
   'Document Serial'= dbo.sp_acc_GetFlexibleNumber(DocumentNumber,DocumentType),      
   'Account'=[AccountsMaster].[AccountName],'Debit'= ISNULL(Debit,0),        
   'Credit'= ISNULL(Credit,0),'Journal Type'= (case when DocumentReference=0 then dbo.LookupDictionaryItem('On Account',Default)        
   else (case when DocumentReference = 2 then dbo.LookupDictionaryItem('Old Reference',Default)         
   else dbo.LookupDictionaryItem('New Reference',Default) end) end),        
   TransactionID,DocumentType,'ReferenceNo' = dbo.sp_acc_getmanualjournalnewreference(TransactionID,[GeneralJournal].[AccountID],1),        
   'Remarks' = dbo.sp_acc_getmanualjournalnewreference(TransactionID,[GeneralJournal].[AccountID],2),        
   'Narration'=[Remarks],'Status' = case when Status = 128 then         
   dbo.LookupDictionaryItem('Amended',Default) when status =192 then dbo.LookupDictionaryItem('Cancelled',Default)         
   when [ReferenceNumber]<>N'' then dbo.LookupDictionaryItem('Amendment',Default) else '' end,        
   'DocType'=[DocumentType],[ReferenceNumber],'ActualID'=[TransactionID],        
   [GeneralJournal].[AccountID],'Voucher No'= VoucherNo, dbo.getledgerdynamicsetting(DocumentType,DocumentReference)         
   from [GeneralJournal],[AccountsMaster] where [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID]         
   and [TransactionID]        
   in (Select [TransactionID] from GeneralJournal where [TransactionDate] >= @fromdate         
   and [TransactionDate]<= @ToDatePair) and ([DocumentType]in (26,37)) order by TransactionID --26-ManualJournal ONACCOUNT,37-ManualJournal OLD REFERENCE        
  End        
  Else        
  Begin        
   select 'TransactionID'= @prefix + cast(DocumentNumber as nvarchar),        
   'Transaction Date'= dbo.stripdatefromtime(TransactionDate),        
   'Document Serial'= dbo.sp_acc_GetFlexibleNumber(DocumentNumber,DocumentType),      
   'Account'=[AccountsMaster].[AccountName],'Debit'= ISNULL(Debit,0),        
   'Credit'= ISNULL(Credit,0),'Journal Type'= (case when DocumentReference=0 then dbo.LookupDictionaryItem('On Account',Default)        
   else (case when DocumentReference = 2 then dbo.LookupDictionaryItem('Old Reference',Default)         
   else dbo.LookupDictionaryItem('New Reference',Default) end) end),        
   TransactionID,DocumentType,'ReferenceNo' = dbo.sp_acc_getmanualjournalnewreference(TransactionID,[GeneralJournal].[AccountID],1),        
   'Remarks' = dbo.sp_acc_getmanualjournalnewreference(TransactionID,[GeneralJournal].[AccountID],2),        
   'Narration'=[Remarks],'Status' = case when Status = 128 then         
   'Amended' when status =192 then dbo.LookupDictionaryItem('Cancelled',Default)         
   when [ReferenceNumber]<>N'' then dbo.LookupDictionaryItem('Amendment',Default) else '' end,        
   'DocType'=[DocumentType],[ReferenceNumber],'ActualID'=[TransactionID],        
   [GeneralJournal].[AccountID],'Voucher No'= VoucherNo, dbo.getledgerdynamicsetting(DocumentType,DocumentReference)         
   from [GeneralJournal],[AccountsMaster] where [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID]         
   and [TransactionID]        
   in (Select [TransactionID]from GeneralJournal where [TransactionDate] >= @fromdate         
   and [TransactionDate]<= @ToDatePair and [AccountID]=@accountid)       
   and ([DocumentType]in (26,37)) order by TransactionID --26-ManualJournal ONACCOUNT,37-ManualJournal OLD REFERENCE        
  End     
 End    
Else    
 Begin    
  If @accountid = 0        
  Begin        
   select 'TransactionID'= @prefix + cast(DocumentNumber as nvarchar),        
   'Transaction Date'= dbo.stripdatefromtime(TransactionDate),        
   'Document Serial'= dbo.sp_acc_GetFlexibleNumber(DocumentNumber,DocumentType),      
   'Account'=[AccountsMaster].[AccountName],'Debit'= ISNULL(Debit,0),        
   'Credit'= ISNULL(Credit,0),'Journal Type'= (case when DocumentReference=0 then dbo.LookupDictionaryItem('On Account',Default)        
   else (case when DocumentReference = 2 then dbo.LookupDictionaryItem('Old Reference',Default)     
   else dbo.LookupDictionaryItem('New Reference',Default) end) end),        
   TransactionID,DocumentType,'ReferenceNo' = dbo.sp_acc_getmanualjournalnewreference(TransactionID,[GeneralJournal].[AccountID],1),        
   'Remarks' = dbo.sp_acc_getmanualjournalnewreference(TransactionID,[GeneralJournal].[AccountID],2),        
   'Narration'=[Remarks],'Status' = case when Status = 128 then         
   dbo.LookupDictionaryItem('Amended',Default) when status =192 then dbo.LookupDictionaryItem('Cancelled',Default)         
   when [ReferenceNumber]<>N'' then dbo.LookupDictionaryItem('Amendment',Default) else '' end,        
   'DocType'=[DocumentType],[ReferenceNumber],'ActualID'=[TransactionID],        
   [GeneralJournal].[AccountID],'Voucher No'= VoucherNo, dbo.getledgerdynamicsetting(DocumentType,DocumentReference)         
   from [GeneralJournal],[AccountsMaster] where [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID]         
   and [TransactionID]        
   in (Select [TransactionID] from GeneralJournal where [TransactionDate] >= @fromdate         
   and [TransactionDate]<= @ToDatePair) and ([DocumentType]in (26,37)) and status not in (128,192) order by TransactionID --26-ManualJournal ONACCOUNT,37-ManualJournal OLD REFERENCE        
  End        
  Else        
  Begin        
   select 'TransactionID'= @prefix + cast(DocumentNumber as nvarchar),        
   'Transaction Date'= dbo.stripdatefromtime(TransactionDate),        
   'Document Serial'= dbo.sp_acc_GetFlexibleNumber(DocumentNumber,DocumentType),      
   'Account'=[AccountsMaster].[AccountName],'Debit'= ISNULL(Debit,0),        
   'Credit'= ISNULL(Credit,0),'Journal Type'= (case when DocumentReference=0 then dbo.LookupDictionaryItem('On Account',Default)        
   else (case when DocumentReference = 2 then dbo.LookupDictionaryItem('Old Reference',Default)         
   else dbo.LookupDictionaryItem('New Reference',Default) end) end),        
   TransactionID,DocumentType,'ReferenceNo' = dbo.sp_acc_getmanualjournalnewreference(TransactionID,[GeneralJournal].[AccountID],1),        
   'Remarks' = dbo.sp_acc_getmanualjournalnewreference(TransactionID,[GeneralJournal].[AccountID],2),        
   'Narration'=[Remarks],'Status' = case when Status = 128 then         
   'Amended' when status =192 then dbo.LookupDictionaryItem('Cancelled',Default)         
   when [ReferenceNumber]<>N'' then dbo.LookupDictionaryItem('Amendment',Default) else '' end,        
   'DocType'=[DocumentType],[ReferenceNumber],'ActualID'=[TransactionID],        
   [GeneralJournal].[AccountID],'Voucher No'= VoucherNo, dbo.getledgerdynamicsetting(DocumentType,DocumentReference)         
   from [GeneralJournal],[AccountsMaster] where [GeneralJournal].[AccountID]=[AccountsMaster].[AccountID]         
   and [TransactionID]        
   in (Select [TransactionID]from GeneralJournal where [TransactionDate] >= @fromdate         
   and [TransactionDate]<= @ToDatePair and [AccountID]=@accountid)       
   and ([DocumentType]in (26,37)) and status not in (128,192) order by TransactionID --26-ManualJournal ONACCOUNT,37-ManualJournal OLD REFERENCE        
  End     
 End
